# Optimize MD3 models - merge two or more surfaces that share textures,
# remove animation frames on static models, etc.
import md3
from operator import eq
from itertools import batched, chain, repeat
from sys import stderr
import argparse


def clean_frames(model: md3.MD3Object):
    """
    Analyze the MD3 file animation, and if there are no changes to the
    vertex positions or tags between the first frame and the last, remove
    the excess frames.

    Returns whether or not any changes were made to the model.
    """
    actually_animated = False
    num_frames = len(model.frames)
    if num_frames == 1:
        print("Not animated, doing nothing.")
        return False
    # Analyze tags
    if model.num_tags > 0:
        frame_one_tags = model.tags[0:model.num_tags]
        for frame_tags in batched(model.tags[model.num_tags:], model.num_tags):
            # If all of the other tags are equal, actually_animated should
            # still be False.
            for tag_first, tag_frame in zip(frame_one_tags, frame_tags):
                actually_animated = actually_animated or (
                    not (all(map(eq, tag_frame.origin, tag_first.origin)) and
                        all(map(eq, tag_frame.axis, tag_first.axis))))
    # It's actually animated, so do nothing.
    if actually_animated:
        print("Tags are animated. No frames removed.")
        return False
    # Analyze each surface
    for surf in model.surfaces:
        nverts = surf.num_verts
        frame_one_verts = surf.verts[:nverts]
        for frame_verts in batched(surf.verts[nverts:], nverts):
            # If all of the other vertices are equal, actually_animated should
            # still be False.
            for verts_first, verts_frame in zip(frame_one_verts, frame_verts):
                actually_animated = actually_animated or (
                    not (all(map(eq, verts_frame.xyz, verts_first.xyz)) and
                         verts_frame.normal == verts_first.normal))
    # It's actually animated, so do nothing.
    if actually_animated:
        print("Vertices are animated. No frames removed.")
        return False
    # Remove excess frames!
    if not actually_animated:
        removed_frames = num_frames - 1  # All MD3s have at least one frame
        model.frames = [model.frames[0]]
        model.tags = model.tags[:model.num_tags]
        for surf in model.surfaces:
            surf.num_frames = 1
            surf.verts = surf.verts[:surf.num_verts]
        print("Removed {removed_frames} excess frames.".format(**locals()))
        return True
    else:
        return False


def merge_surfaces(model: md3.MD3Object):
    """
    Analyze the surfaces of the model, and if there are two or more surfaces
    that share a texture, merge the two surfaces together.

    Returns whether or not any changes were made to the model.
    """
    # MD3 model surfaces typically use only one texture/shader. So which
    # surfaces use which textures?
    def textures_for_surfaces(model: md3.MD3Object):
        texture_surfaces = {}
        for sidx, surf in enumerate(model.surfaces):
            texture = surf.shader.name
            surfaces = texture_surfaces.setdefault(texture, [])
            surfaces.append(sidx)
        # Sort the lists in descending order, because I want to remove the last
        # ones first.
        for texture in texture_surfaces:
            texture_surfaces[texture].sort()
        return texture_surfaces
    texture_surfaces = textures_for_surfaces(model)
    texture_list = [texture for texture in texture_surfaces.keys()]
    changes = False
    # Merge the surfaces
    for texture in texture_list:
        surface_indices = texture_surfaces[texture]
        if len(surface_indices) > 1:
            # Merge them into a new surface, with vertices, triangles, and
            # texture coordinates from all the other surfaces
            new_surface = md3.MD3Surface()
            new_surface.num_frames = len(model.frames)
            new_surface.num_verts = sum(map(
                lambda ms: ms.num_verts,
                map(lambda sf: sf[1],  # enumerate gives (index, object) pairs
                    filter(lambda sf: sf[0] in surface_indices,
                        enumerate(model.surfaces))),
            ))
            new_surface.shader.name = texture
            # Each triangle is a triple of vertex indices. Since I'm dealing
            # with multiple surfaces here, I need to add this to the indices of
            # subsequent subfaces' vertex indices.
            add_vert_index = 0
            for sidx in surface_indices:
                surf = model.surfaces[sidx]
                new_surface.triangles.extend(
                    map(lambda t: md3.MD3Triangle(
                        [i + add_vert_index for i in t.indexes]
                    ), surf.triangles)
                )
                add_vert_index += surf.num_verts
            new_surface.uv = list(chain.from_iterable(map(
                lambda ms: ms.uv,
                map(lambda sf: sf[1],  # enumerate gives (index, object) pairs
                    filter(lambda sf: sf[0] in surface_indices,
                        enumerate(model.surfaces))),
            )))
            # An iterable for each surface
            verts_each_surf = [batched(surf.verts, surf.num_verts) for surf in
                               map(lambda sf: sf[1],
                                   filter(lambda sf: sf[0] in surface_indices,
                                          enumerate(model.surfaces)))]
            # Get from first iterator, then the second, then the third, etc.
            for _ in range(len(model.frames)):
                for it in verts_each_surf:
                    new_surface.verts.extend(next(it))
            # Replace first surface with the new one, remove other surfaces
            # The model will change after each merge
            model.surfaces[surface_indices[0]] = new_surface
            for sidx in reversed(surface_indices[1:]):
                del model.surfaces[sidx]
            # Done with this surface
            print("Merged", len(surface_indices),
                  "surfaces with texture", texture)
            # Re-write the surface index lists, because with less surfaces, the
            # indices for all the following surfaces will have changed.
            texture_surfaces = textures_for_surfaces(model)
            changes = True
    return changes


def validate_model(model: md3.MD3Object):
    """
    Returns whether or not all the vertices, UVs, and triangles are of the
    correct type.
    """
    for sidx, surf in enumerate(model.surfaces):
        # Vertices
        verts_correct = (
            all(map(isinstance, surf.verts, repeat(md3.MD3Vertex))))
        # UVs
        uvs_correct = (
            all(map(isinstance, surf.uv, repeat(md3.MD3TexCoord))))
        # Triangles
        tris_correct = (
            all(map(isinstance, surf.triangles, repeat(md3.MD3Triangle))))
        if not all([verts_correct, uvs_correct, tris_correct]):
            print("Surface {sidx} verts[0]:".format(**locals()), surf.verts[0])
            print("Surface {sidx} uv[0]:".format(**locals()), surf.uv[0])
            print("Surface {sidx} triangles[0]:".format(**locals()),
                  surf.triangles[0])
            print("ERROR: Some types are not correct!")
            return False
        else:
            return True


def optimize_model(model_filename, options={}):
    with open(model_filename, "rb") as md3f:
        try:
            model = md3.MD3Object.read(md3f)
        except Exception as err:
            print(
                "Failed to read MD3 model "
                "{model_filename}: {err}".format(**locals()),
                file=stderr
            )
            model = None
    if model is not None:
        changes = clean_frames(model)
        changes = changes or merge_surfaces(model)
        validate_model(model)
        if not options.get("dry_run") and changes:
            with open(model_filename, "wb") as md3f:
                model.save(md3f, options)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="optimd3.py",
        description="Optimizes MD3 models for rendering performance"
    )
    parser.add_argument(
        "filename",
        help="The MD3 file to optimize"
    )
    parser.add_argument(
        "--dry-run", "-d",
        help="Do not save the optimized MD3 model",
        action="store_true"
    )
    args = parser.parse_args()
    optimize_model(args.filename, vars(args))
