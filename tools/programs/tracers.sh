#!/usr/bin/env zsh
# Find all uses of BulletTracer and its subclasses

# Find all subclasses of a given class
get_subclasses_of(){
	grep -Prio "[Cc][Ll][Aa][Ss][Ss]\s+\w[^\s:]+\s*:\s*${1}" ${2:-scripts} | sed -E 's/^[^:]+:class[[:space:]]+([[:alpha:]][^[:space:]:]+).+/\1/g'
}

tracerclasses=()

add_tracer_class(){
	tracerclasses+=($1)
}
add_tracer_classes(){
	for tclass in $@; do tracerclasses+=($tclass); done
}
add_subclasses(){
	: ${(Af)subclasses::="$(get_subclasses_of $1)"}
	add_tracer_classes $subclasses
	for tclass in $subclasses; do
		add_subclasses $tclass
	done
}

: ${(Af)tracers::="$(get_subclasses_of BulletTracer)"}

for tclass in $tracers; do
	add_tracer_class $tclass
	add_subclasses $tclass
done

for tclass in $tracerclasses; do
	grep -rin $tclass scripts
done