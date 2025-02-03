# Optimize MD3 models - merge two or more surfaces that share textures,
# remove animation frames on static models, etc.
#
# MD3 library. Code from GZDoom MD3 import/export script:
# https://github.com/nashmuhandes/io_export_gzdoom_md3
import struct
from io import SEEK_SET

MAX_QPATH = 64

MD3_IDENT = "IDP3"
MD3_VERSION = 15
MD3_MAX_TAGS = 16
MD3_MAX_SURFACES = 32
MD3_MAX_FRAMES = 1024
MD3_MAX_SHADERS = 256
MD3_MAX_VERTICES = 8192    #4096
MD3_MAX_TRIANGLES = 16384  #8192
MD3_XYZ_SCALE = 64.0
# https://www.icculus.org/homepages/phaethon/q3a/formats/md3format.html#Normals
MD3_UP_NORMAL = 0
MD3_DOWN_NORMAL = 32768  # 128 << 8


def unmd3_string(data):
    "Given a byte slice taken from a C string, return a bytes object suitable "
    "for decoding to a UTF-8 string."
    null_pos = data.find(b"\0")
    data = data[0:null_pos]
    return data


class MD3Vertex:
    binary_format = "<3hH"

    def __init__(self):
        self.xyz = (0, 0, 0)
        self.normal = 0

    @staticmethod
    def get_size():
        return struct.calcsize(MD3Vertex.binary_format)

    @staticmethod
    def encode_xyz(xyz):
        "Convert an XYZ vector to an MD3 integer vector"
        def convert(number, factor):
            return floor(number * factor)
        factors = [MD3_XYZ_SCALE] * 3
        position = map(convert, xyz, factors)
        return tuple(map(int, position))

    @staticmethod
    def decode_xyz(xyz):
        "Convert an MD3 integer vector to a XYZ vector"
        def convert(number, factor):
            return number / factor
        factors = [MD3_XYZ_SCALE] * 3
        position = map(convert, xyz, factors)
        return Vector(position)

    # copied from PhaethonH <phaethon@linux.ucla.edu> md3.py
    @staticmethod
    def encode_normal(normal, gzdoom=True):
        n = normal.normalized()

        # Export for Quake 3 rather than GZDoom
        if not gzdoom:
            if n.z == 1.0:
                return MD3_UP_NORMAL
            elif n.z == -1.0:
                return MD3_DOWN_NORMAL

        lng = math.acos(n.z) * 255 / (2 * math.pi)
        lat = math.atan2(n.y, n.x) * 255 / (2 * math.pi)
        lng_byte = int(lng) & 0xFF
        lat_byte = int(lat) & 0xFF

        return (lat_byte << 8) | (lng_byte)

    # copied from PhaethonH <phaethon@linux.ucla.edu> md3.py
    @staticmethod
    def decode_normal(latlng, gzdoom=True):
        # Import from Quake 3 rather than GZDoom
        if not gzdoom:
            if latlng == MD3_UP_NORMAL:
                return Vector((0.0, 0.0, 1.0))
            elif latlng == MD3_DOWN_NORMAL:
                return Vector((0.0, 0.0, -1.0))

        lat = (latlng >> 8) & 0xFF
        lng = (latlng) & 0xFF
        lat *= math.pi / 128
        lng *= math.pi / 128

        x = math.cos(lat) * math.sin(lng)
        y = math.sin(lat) * math.sin(lng)
        z =                 math.cos(lng)

        return Vector((x, y, z))

    @staticmethod
    def encode(xyz, normal, gzdoom=True):
        xyz = MD3Vertex.encode_xyz(xyz)
        normal = MD3Vertex.encode_normal(normal, gzdoom)
        return xyz, normal

    @staticmethod
    def decode(xyz, normal, gzdoom=True):
        xyz = MD3Vertex.decode_xyz(xyz)
        normal = MD3Vertex.decode_normal(normal, gzdoom)
        return xyz, normal

    @staticmethod
    def read(file):
        data = file.read(MD3Vertex.get_size())
        data = struct.unpack(MD3Vertex.binary_format, data)
        nvertex = MD3Vertex()
        nvertex.xyz = tuple(data[0:3])
        nvertex.normal = data[3]
        return nvertex

    def save(self, file, options={}):
        data = struct.pack(self.binary_format, *self.xyz, self.normal)
        file.write(data)

class MD3TexCoord:
    binary_format = "<2f"

    def __init__(self):
        self.u = 0.0
        self.v = 0.0

    @staticmethod
    def get_size():
        return struct.calcsize(MD3TexCoord.binary_format)

    @staticmethod
    def read(file):
        data = file.read(MD3TexCoord.get_size())
        data = struct.unpack(MD3TexCoord.binary_format, data)
        ntexcoord = MD3TexCoord()
        ntexcoord.u = data[0]
        ntexcoord.v = data[1]
        return ntexcoord

    def save(self, file, options={}):
        uv_x = self.u
        uv_y = 1.0 - self.v if options.get("blender", False) else self.v
        data = struct.pack(self.binary_format, uv_x, uv_y)
        file.write(data)

class MD3Triangle:
    binary_format = "<3i"

    def __init__(self, indexes=None):
        self.indexes = [ 0, 0, 0 ] if indexes is None else indexes

    @staticmethod
    def get_size():
        return struct.calcsize(MD3Triangle.binary_format)

    @staticmethod
    def read(file):
        data = file.read(MD3Triangle.get_size())
        data = struct.unpack(MD3Triangle.binary_format, data)
        ntri = MD3Triangle()
        ntri.indexes = data[:]
        return ntri

    def save(self, file, options={}):
        indexes = self.indexes[:]
        if options.get("blender", False):
            indexes[1:3] = reversed(indexes[1:3])  # Winding order fix
        data = struct.pack(self.binary_format, *indexes)
        file.write(data)

class MD3Shader:
    binary_format = "<%dsi" % MAX_QPATH

    def __init__(self):
        self.name = ""
        self.index = 0

    @staticmethod
    def get_size():
        return struct.calcsize(MD3Shader.binary_format)

    @staticmethod
    def read(file):
        data = file.read(MD3Shader.get_size())
        data = struct.unpack(MD3Shader.binary_format, data)
        nshader = MD3Shader()
        nshader.name = unmd3_string(data[0]).decode()
        nshader.index = data[1]
        return nshader

    def save(self, file, options={}):
        name = str.encode(self.name)
        data = struct.pack(self.binary_format, name, self.index)
        file.write(data)

class MD3Surface:
    binary_format = "<4s%ds10i" % MAX_QPATH  # 1 int, name, then 10 ints

    def __init__(self):
        self.ident = MD3_IDENT
        self.name = ""
        self.flags = 0
        self.num_frames = 0
        self.num_verts = 0
        self.ofs_triangles = 0
        self.ofs_shaders = 0
        self.ofs_uv = 0
        self.ofs_verts = 0
        self.ofs_end = 0
        self.shader = MD3Shader()
        self.triangles = []
        self.uv = []
        self.verts = []

        self.size = 0

    def get_size(self):
        if self.size > 0:
            return self.size
        # Triangles (after header)
        self.ofs_triangles = struct.calcsize(self.binary_format)

        # Shader (after triangles)
        self.ofs_shaders = self.ofs_triangles + (
            MD3Triangle.get_size() * len(self.triangles))

        # UVs (after shader)
        self.ofs_uv = self.ofs_shaders + MD3Shader.get_size()

        # Vertices for each frame (after UVs)
        self.ofs_verts = self.ofs_uv + MD3TexCoord.get_size() * len(self.uv)

        # End (after vertices)
        self.ofs_end = self.ofs_verts + MD3Vertex.get_size() * len(self.verts)
        self.size = self.ofs_end
        return self.ofs_end

    @staticmethod
    def read(file):
        surface_start = file.tell()
        data = file.read(struct.calcsize(MD3Surface.binary_format))
        data = struct.unpack(MD3Surface.binary_format, data)
        if data[0] != b"IDP3":
            return None
        nsurf = MD3Surface()
        # nsurf.ident = data[0]
        nsurf.name = unmd3_string(data[1]).decode()
        nsurf.flags = data[2]
        nsurf.num_frames = data[3]
        num_shaders = data[4]
        nsurf.num_verts = data[5]
        num_tris = data[6]
        nsurf.ofs_triangles = data[7]
        nsurf.ofs_shaders = data[8]
        nsurf.ofs_uv = data[9]
        nsurf.ofs_verts = data[10]
        nsurf.ofs_end = data[11]

        file.seek(surface_start + nsurf.ofs_shaders, SEEK_SET)
        shaders = [MD3Shader.read(file) for x in range(num_shaders)]
        # Temporary workaround for the lack of support for multiple shaders
        # Most MD3 surfaces only use one shader anyways
        nsurf.shader = shaders[0]

        file.seek(surface_start + nsurf.ofs_triangles, SEEK_SET)
        nsurf.triangles = [MD3Triangle.read(file) for x in range(num_tris)]

        file.seek(surface_start + nsurf.ofs_uv, SEEK_SET)
        nsurf.uv = [MD3TexCoord.read(file) for x in range(nsurf.num_verts)]

        num_verts = nsurf.num_verts * nsurf.num_frames  # Vertex animation
        file.seek(surface_start + nsurf.ofs_verts, SEEK_SET)
        nsurf.verts = [MD3Vertex.read(file) for x in range(num_verts)]

        file.seek(surface_start + nsurf.ofs_end, SEEK_SET)
        return nsurf

    def save(self, file, options={}):
        self.get_size()
        temp_data = [0] * 12
        temp_data[0] = str.encode(self.ident)
        temp_data[1] = str.encode(self.name)
        temp_data[2] = self.flags
        temp_data[3] = self.num_frames
        temp_data[4] = 1  # len(self.shaders) # self.num_shaders
        temp_data[5] = self.num_verts
        temp_data[6] = len(self.triangles)  # self.num_triangles
        temp_data[7] = self.ofs_triangles
        temp_data[8] = self.ofs_shaders
        temp_data[9] = self.ofs_uv
        temp_data[10] = self.ofs_verts
        temp_data[11] = self.ofs_end
        data = struct.pack(self.binary_format, *temp_data)
        file.write(data)

        # write the tri data
        for t in self.triangles:
            t.save(file, options)

        # save the shaders
        self.shader.save(file, options)

        # save the uv info
        for u in self.uv:
            u.save(file, options)

        # save the verts
        for v in self.verts:
            v.save(file, options)

class MD3Tag:
    binary_format="<%ds3f9f" % MAX_QPATH

    def __init__(self):
        self.name = ""
        self.origin = [0, 0, 0]
        self.axis = [0, 0, 0, 0, 0, 0, 0, 0, 0]

    @staticmethod
    def get_size():
        return struct.calcsize(MD3Tag.binary_format)

    @staticmethod
    def read(file):
        data = file.read(MD3Tag.get_size())
        data = struct.unpack(MD3Tag.binary_format, data)
        ntag = MD3Tag()
        ntag.name = unmd3_string(data[0]).decode()
        ntag.origin = data[1:4]
        ntag.axis = data[4:13]
        return ntag

    def save(self, file, options={}):
        temp_data = [0] * 13
        temp_data[0] = str.encode(self.name)
        temp_data[1] = float(self.origin[0])
        temp_data[2] = float(self.origin[1])
        temp_data[3] = float(self.origin[2])
        temp_data[4] = float(self.axis[0])
        temp_data[5] = float(self.axis[1])
        temp_data[6] = float(self.axis[2])
        temp_data[7] = float(self.axis[3])
        temp_data[8] = float(self.axis[4])
        temp_data[9] = float(self.axis[5])
        temp_data[10] = float(self.axis[6])
        temp_data[11] = float(self.axis[7])
        temp_data[12] = float(self.axis[8])
        data = struct.pack(self.binary_format, *temp_data)
        file.write(data)

class MD3Frame:
    binary_format="<3f3f3ff16s"

    def __init__(self):
        self.mins = [0, 0, 0]
        self.maxs = [0, 0, 0]
        self.local_origin = [0, 0, 0]
        self.radius = 0.0
        self.name = ""

    @staticmethod
    def get_size():
        return struct.calcsize(MD3Frame.binary_format)

    @staticmethod
    def read(file):
        data = file.read(MD3Frame.get_size())
        data = struct.unpack(MD3Frame.binary_format, data)
        nframe = MD3Frame()
        nframe.mins = data[0:3]
        nframe.maxs = data[3:6]
        nframe.local_origin = data[6:9]
        nframe.radius = data[9]
        nframe.name = unmd3_string(data[10]).decode()
        return nframe

    def save(self, file, options={}):
        temp_data = [0] * 11
        temp_data[0] = self.mins[0]
        temp_data[1] = self.mins[1]
        temp_data[2] = self.mins[2]
        temp_data[3] = self.maxs[0]
        temp_data[4] = self.maxs[1]
        temp_data[5] = self.maxs[2]
        temp_data[6] = self.local_origin[0]
        temp_data[7] = self.local_origin[1]
        temp_data[8] = self.local_origin[2]
        temp_data[9] = self.radius
        temp_data[10] = self.name.encode()
        data = struct.pack(self.binary_format, *temp_data)
        file.write(data)

class MD3Object:
    binary_format="<4si%ds9i" % MAX_QPATH  # little-endian (<), 17 integers (17i)

    def __init__(self):
        # header structure
        # this is used to identify the file (must be IDP3)
        self.ident = MD3_IDENT
        # the version number of the file (Must be 15)
        self.version = MD3_VERSION
        self.name = ""
        self.flags = 0
        self.num_tags = 0
        self.num_skins = 0
        self.ofs_frames = 0
        self.ofs_tags = 0
        self.ofs_surfaces = 0
        self.ofs_end = 0
        self.frames = []
        self.tags = []
        self.surfaces = []

        self.size = 0

    def get_size(self):
        if self.size > 0:
            return self.size
        # Frames (after header)
        self.ofs_frames = struct.calcsize(self.binary_format)

        # Tags (after frames)
        self.ofs_tags = self.ofs_frames + (
            len(self.frames) * MD3Frame.get_size())

        # Surfaces (after tags)
        self.ofs_surfaces = self.ofs_tags + (
            len(self.tags) * MD3Tag.get_size())
        # Surfaces' sizes can vary because they contain collections of
        # triangles, vertices, and UV coordinates
        self.ofs_end = self.ofs_surfaces + sum(
            map(lambda s: s.get_size(), self.surfaces))

        self.size = self.ofs_end
        return self.ofs_end

    @staticmethod
    def read(file):
        md3_start = file.tell()
        data = file.read(struct.calcsize(MD3Object.binary_format))
        data = struct.unpack(MD3Object.binary_format, data)
        if data[0] != b"IDP3":
            return None
        nobj = MD3Object()
        # nobj.ident = data[0]
        nobj.version = data[1]
        nobj.name = unmd3_string(data[2]).decode()
        nobj.flags = data[3]
        num_frames = data[4]
        nobj.num_tags = data[5]
        num_surfaces = data[6]
        nobj.num_skins = data[7]
        nobj.ofs_frames = data[8]
        nobj.ofs_tags = data[9]
        nobj.ofs_surfaces = data[10]
        nobj.ofs_end = data[11]

        file.seek(md3_start + nobj.ofs_frames, SEEK_SET)
        nobj.frames = [MD3Frame.read(file) for x in range(num_frames)]

        file.seek(md3_start + nobj.ofs_tags, SEEK_SET)
        num_tags = nobj.num_tags * num_frames
        nobj.tags = [MD3Tag.read(file) for x in range(num_tags)]

        file.seek(md3_start + nobj.ofs_surfaces, SEEK_SET)
        nobj.surfaces = [MD3Surface.read(file) for x in range(num_surfaces)]

        file.seek(md3_start + nobj.ofs_end, SEEK_SET)
        return nobj

    def save(self, file, options={}):
        self.get_size()
        temp_data = [0] * 12
        temp_data[0] = str.encode(self.ident)
        temp_data[1] = self.version
        temp_data[2] = str.encode(self.name)
        temp_data[3] = self.flags
        temp_data[4] = len(self.frames)  # self.num_frames
        temp_data[5] = self.num_tags
        temp_data[6] = len(self.surfaces)  # self.num_surfaces
        temp_data[7] = self.num_skins
        temp_data[8] = self.ofs_frames
        temp_data[9] = self.ofs_tags
        temp_data[10] = self.ofs_surfaces
        temp_data[11] = self.ofs_end

        data = struct.pack(self.binary_format, *temp_data)
        file.write(data)

        for f in self.frames:
            f.save(file, options)

        for t in self.tags:
            t.save(file, options)

        for s in self.surfaces:
            s.save(file, options)

__all__ = ["MD3Vertex", "MD3TexCoord", "MD3Triangle", "MD3Shader",
           "MD3Surface", "MD3Tag", "MD3Frame", "MD3Object", "MAX_QPATH"]
