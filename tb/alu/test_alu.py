import random
import cocotb
from cocotb.triggers import Timer

MASK = 0xFFFF_FFFF
ADD, SUB, SLL, SLT, SLTU = 0b0000, 0b1000, 0b0001, 0b0010, 0b0011
XOR, SRL, SRA, OR, AND   = 0b0100, 0b0101, 0b1101, 0b0110, 0b0111

OPS = [ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND]   # add each op here once its reference model works

def to_signed(x):
    return x - (1 << 32) if x & 0x8000_0000 else x

def ref_alu(op, a, b):
    """What the hardware *should* output, computed in Python."""
    if op == ADD: return (a + b) & MASK
    if op == SUB: return (a - b) & MASK
    if op == SLL: return (a << (b & 31)) & MASK
    if op == SLT: return (to_signed(a) < to_signed(b)) & MASK
    if op == SLTU: return (a < b) & MASK
    if op == XOR: return (a ^ b) & MASK
    if op == SRL: return (a >> (b & 31)) & MASK
    if op == SRA: return (to_signed(a) >> (b & 31)) & MASK
    if op == OR: return (a | b) & MASK
    if op == AND: return (a & b) & MASK
    # TODO: SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
    raise ValueError(f"no model for op {op:04b}")

async def check(dut, op, a, b):
    dut.a.value, dut.b.value, dut.alu_ctrl.value = a, b, op
    await Timer(1, unit="ns")            # let the combinational logic settle
    got, exp = int(dut.result.value), ref_alu(op, a, b)
    assert got == exp, (f"op={op:04b} a={a:#010x} b={b:#010x}: "
                        f"got {got:#010x}, expected {exp:#010x}")

CORNERS = [0, 1, 31, 0x21, 0x7FFF_FFFF, 0x8000_0000, MASK]

@cocotb.test()
async def test_corners(dut):
    for op in OPS:
        for a in CORNERS:
            for b in CORNERS:
                await check(dut, op, a, b)

@cocotb.test()
async def test_random(dut):
    rng = random.Random(154)
    for _ in range(5000):
        await check(dut, rng.choice(OPS), rng.getrandbits(32), rng.getrandbits(32))