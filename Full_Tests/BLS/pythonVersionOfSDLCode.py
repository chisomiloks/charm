from charm.toolbox.pairinggroup import *
from charm.core.engine.util import *

h = {}
group = None

def keygen():
    input = None
    g = group.random(G2)
    x = group.random(ZR)
    pk = (g ** x)
    sk = x
    output = (pk, sk, g)
    return output

def sign(sk, M):
    input = [sk, M]
    sig = (group.hash(M, G1) ** sk)
    output = sig
    return output

def verify(pk, M, sig, g):
    global h

    input = [pk, M, sig, g]
    h = group.hash(M, G1)
    verify = ( (pair(h, pk)) == (pair(sig, g)) )
    output = verify
    return output

def main():
    global group

    group = PairingGroup(80)

    #print(group)

    (pk, sk, g) = keygen()
    sig = sign(sk, "test")
    #print(verify(pk, "test2", sig, g))

if __name__ == "__main__":
    main()
