"""cocotb test for the scaffolding multiplier.

Pattern to reuse for the core: drive inputs, compare against a Python
reference model, and hammer it with random vectors plus corner cases.
"""

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

MASK32 = 0xFFFF_FFFF


async def reset(dut):
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.a.value = 0
    dut.b.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


async def multiply(dut, a, b):
    dut.a.value = a
    dut.b.value = b
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0
    for _ in range(40):
        await RisingEdge(dut.clk)
        if int(dut.done.value):
            return int(dut.product.value)
    raise AssertionError(f"timeout waiting for done (a={a:#x}, b={b:#x})")


@cocotb.test()
async def test_corner_cases(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    cases = [(0, 0), (1, 1), (MASK32, MASK32), (MASK32, 1), (0x8000_0000, 2),
             (12345, 0), (0, 67890)]
    for a, b in cases:
        got = await multiply(dut, a, b)
        assert got == a * b, f"{a:#x} * {b:#x}: got {got:#x}, expected {a * b:#x}"


@cocotb.test()
async def test_random(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset(dut)
    rng = random.Random(154)
    for _ in range(500):
        a, b = rng.getrandbits(32), rng.getrandbits(32)
        got = await multiply(dut, a, b)
        assert got == a * b, f"{a:#x} * {b:#x}: got {got:#x}, expected {a * b:#x}"
