# Build the code we use for some tests

BIN_SFILES = $(filter-out s/_%,$(wildcard s/*))
MODULE_SFILES = $(wildcard module/s/*)
UTIL_SFILES = $(wildcard utility/s/*)
ABS_SFILES = $(filter-out absolute/s/_%,$(wildcard absolute/s/*))
LOADEXEC_SFILES = $(wildcard loadexec/s/*)

all: \
	dirs \
	${BIN_SFILES:s/%=bin/%,ffc} \
	${MODULE_SFILES:module/s/%=module/bin/%,ffa} \
	${UTIL_SFILES:utility/s/%=utility/bin/%,ffc} \
	${ABS_SFILES:absolute/s/%=absolute/bin/%,ff8} \
	${LOADEXEC_SFILES:loadexec/s/%=loadexec/bin/%,00008000,00008000}

bin/%,ffc: s/%
	riscos-objasm -apcs 3/32 -o o/$* $? && riscos-link -bin -o $@ o/$* && mv bin/$*,ffd $@

absolute/bin/%,ff8: absolute/s/%
	riscos-objasm -apcs 3/32 -o absolute/o/$* $? && riscos-link -bin -o $@ absolute/o/$* && mv absolute/bin/$*,ffd $@

module/bin/%,ffa: module/s/%
	riscos-objasm -apcs 3/32 -o module/o/$* $? && riscos-link -bin -o $@ module/o/$* && mv module/bin/$*,ffd $@

utility/bin/%,ffc: utility/s/%
	riscos-objasm -apcs 3/32 -o utility/o/$* $? && riscos-link -bin -o $@ utility/o/$* && mv utility/bin/$*,ffd $@

# The 'loadexec' files are just the sources, so that they can be copied to the right names we don't specify the
# load and exec address in this file
loadexec/bin/%,00008000,00008000: loadexec/s/%
	riscos-objasm -apcs 3/32 -o loadexec/o/$* $? && riscos-link -bin -o $@ loadexec/o/$* && mv loadexec/bin/$*,ffd $@

dirs:
	@mkdir -p o
	@mkdir -p absolute/o
	@mkdir -p module/o
	@mkdir -p utility/o

MODULE = MessageTrans

tests-messagetrans.txt: tests-messagetrans-pyro.txt transform-pyro-tests-to-buildservice.sh
	./transform-pyro-tests-to-buildservice.sh tests-messagetrans-pyro.txt $@

${MODULE},ffa: ../rm32/${MODULE},ffa
	cp $? $@

tests: ${MODULE},ffa tests-messagetrans.txt run-on-build-service.sh test.pl
	./test.pl --show-command --show-diff ./run-on-build-service.sh .
