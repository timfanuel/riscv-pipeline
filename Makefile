# Top-level convenience targets. Run `source scripts/env.sh` first.
SIM ?= icarus

.PHONY: test-flow harden-flow clean

test-flow:
	$(MAKE) -C tb/flow_test SIM=$(SIM)

# Run from the repo root so the Docker container can see rtl/.
harden-flow:
	openlane --dockerized openlane/mul_shift_add/config.json

clean:
	$(MAKE) -C tb/flow_test clean
	rm -rf tb/*/sim_build tb/*/results.xml tb/*/*.fst tb/*/__pycache__
	rm -rf openlane/*/runs
