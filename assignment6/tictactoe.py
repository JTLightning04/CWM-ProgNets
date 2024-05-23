#!/usr/bin/env python3

import re

from scapy.all import *

class P4calc(Packet):
    name = "P4calc"
    fields_desc = [ StrFixedLenField("P", "P", length=1),
                    StrFixedLenField("Four", "4", length=1),
                    XByteField("version", 0x01),
                    StrFixedLenField("op", "+", length=1),
                    IntField("operand_a", 0),
                    IntField("operand_b", 0),
                    IntField("operand_c", 0),
                    IntField("operand_d", 0),
                    IntField("operand_e", 0),
                    IntField("operand_f", 0),
                    IntField("operand_g", 0),
                    IntField("operand_h", 0),
                    IntField("operand_i", 0),
                    IntField("result", 0xDEADBABE)]

bind_layers(Ether, P4calc, type=0x1234)

class NumParseError(Exception):
    pass

class OpParseError(Exception):
    pass

class Token:
    def __init__(self,type,value = None):
        self.type = type
        self.value = value

def num_parser(s, i, ts):
    pattern = "^\s*([0-9]+)\s*"
    match = re.match(pattern,s[i:])
    if match:
        ts.append(Token('num', match.group(1)))
        return i + match.end(), ts
    raise NumParseError('Expected number literal.')


def op_parser(s, i, ts):
    pattern = "^\s*([-+&|^])\s*"
    match = re.match(pattern,s[i:])
    if match:
        ts.append(Token('num', match.group(1)))
        return i + match.end(), ts
    raise NumParseError("Expected binary operator '-', '+', '&', '|', or '^'.")


def make_seq(p1, p2):
    def parse(s, i, ts):
        i,ts2 = p1(s,i,ts)
        return p2(s,i,ts2)
    return parse

def get_if():
    ifs=get_if_list()
    iface= "veth0-1" # "h1-eth0"
    #for i in get_if_list():
    #    if "eth0" in i:
    #        iface=i
    #        break;
    #if not iface:
    #    print("Cannot find eth0 interface")
    #    exit(1)
    #print(iface)
    return iface

def display_board(a,b,c,d,e,f,g,h,i):
    print('board:')
    print(str(a)+' '+str(b)+' '+str(c))
    print(str(d)+' '+str(e)+' '+str(f))
    print(str(g)+' '+str(h)+' '+str(i))

def main():

    p = make_seq(num_parser, make_seq(op_parser,num_parser))
    s = ''
    #iface = get_if()
    iface = "enx0c37965f8a16"
    
    #initialise the game
    place_a = 0
    place_b = 0
    place_c = 0
    place_d = 0
    place_e = 0
    place_f = 0
    place_g = 0
    place_h = 0
    place_i = 0
    valid = 0
    turn = 0
    
    #explanation of how to play
    print('On your turn type the position you want to play corresponding to these numbers:')
    print('1 2 3')
    print('4 5 6')
    print('7 8 9')
    print('your moves will be represented by 1 and the computer moves by 2')
    while True:
        s = input('board:\n'+str(place_a)+' '+str(place_b)+' '+str(place_c)+'\n'+str(place_d)+' '+str(place_e)+' '+str(place_f)+'\n'+str(place_g)+' '+str(place_h)+' '+str(place_i)+'\n > ')
        if s == "quit":
            break
        print(s)
        valid = 0
        if s == '1':
            if place_a == 0:
            	valid = 1
            	place_a = 1
            else:
            	valid = 0
       	elif s == '2':
            if place_b == 0:
            	valid = 1
            	place_b = 1
            else:
            	valid = 0
        elif s == '3':
            if place_c == 0:
            	valid = 1
            	place_c = 1
            else:
            	valid = 0
        elif s == '4':
            if place_d == 0:
            	valid = 1
            	place_d = 1
            else:
            	valid = 0
        elif s == '5':
            if place_e == 0:
            	valid = 1
            	place_e = 1
            else:
            	valid = 0
        elif s == '6':
            if place_f == 0:
            	valid = 1
            	place_f = 1
            else:
            	valid = 0
        elif s == '7':
            if place_g == 0:
            	valid = 1
            	place_g = 1
            else:
            	valid = 0
        elif s == '8':
            if place_h == 0:
            	valid = 1
            	place_h = 1
            else:
            	valid = 0
        elif s == '9':
            if place_i == 0:
            	valid = 1
            	place_i = 1
            else:
            	valid = 0
        if valid == 1:
        
            try:
                pkt = Ether(dst='00:04:00:00:00:00', type=0x1234) / P4calc(op='+',
                                                  operand_a=int(place_a),
                                                  operand_b=int(place_b),
                                                  operand_c=int(place_c),
                                                  operand_d=int(place_d),
                                                  operand_e=int(place_e),
                                                  operand_f=int(place_f),
                                                  operand_g=int(place_g),
                                                  operand_h=int(place_h),
                                                  operand_i=int(place_i))

                pkt = pkt/' '

                #pkt.show()
                resp = srp1(pkt, iface=iface,timeout=5, verbose=False)
                if resp:
                    p4calc=resp[P4calc]
                    if p4calc:
                        if str(p4calc.result) == '1':
                            place_a = 2
                        elif str(p4calc.result) == '2':
                            place_b = 2
                        elif str(p4calc.result) == '3':
                            place_c = 2
                        elif str(p4calc.result) == '4':
                            place_d = 2
                        elif str(p4calc.result) == '5':
                            place_e = 2
                        elif str(p4calc.result) == '6':
                            place_f = 2
                        elif str(p4calc.result) == '7':
                            place_g = 2
                        elif str(p4calc.result) == '8':
                            place_h = 2
                        elif str(p4calc.result) == '9':
                            place_i = 2
                        elif str(p4calc.result) == '10':
                            print('you win')
                            break
                        elif str(p4calc.result) == '11':
                            print('you lose')
                            place_a = p4calc.operand_a
                            place_b = p4calc.operand_b
                            place_c = p4calc.operand_c
                            place_d = p4calc.operand_d
                            place_e = p4calc.operand_e
                            place_f = p4calc.operand_f
                            place_g = p4calc.operand_g
                            place_h = p4calc.operand_h
                            place_i = p4calc.operand_i
                            break
                        elif str(p4calc.result) == '12':
                            print('draw')
                            break
                        
                    else:
                        print("cannot find P4calc header in the packet")
                else:
                    print("Didn't receive response")
            except Exception as error:
                print(error)
        else:
            print("invalid move")
    display_board(place_a,place_b,place_c,place_d,place_e,place_f,place_g,place_h,place_i)

if __name__ == '__main__':
    main()

