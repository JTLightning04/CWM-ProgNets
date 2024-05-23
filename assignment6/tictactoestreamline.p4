/* -*- P4_16 -*- */

/* P4 TicTacToe */


#include <core.p4>
#include <v1model.p4>

/*
 * Standard Ethernet header
 */
header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

/*
 * This is a custom protocol header for the calculator. We'll use
 * etherType 0x1234 for it (see parser)
 */
const bit<16> P4CALC_ETYPE = 0x1234;
const bit<8>  P4CALC_P     = 0x50;   // 'P'
const bit<8>  P4CALC_4     = 0x34;   // '4'
const bit<8>  P4CALC_VER   = 0x01;   // v0.1
const bit<8>  P4CALC_PLUS  = 0x2b;   // '+'

header p4calc_t {
    bit<8> p;
    bit<8> four;
    bit<8> ver;
    bit<8>  op;
    bit<32> operand_a;
    bit<32> operand_b;
    bit<32> operand_c;
    bit<32> operand_d;
    bit<32> operand_e;
    bit<32> operand_f;
    bit<32> operand_g;
    bit<32> operand_h;
    bit<32> operand_i;
    bit<32> res;
}

/*
 * All headers, used in the program needs to be assembled into a single struct.
 * We only need to declare the type, but there is no need to instantiate it,
 * because it is done "by the architecture", i.e. outside of P4 functions
 */
struct headers {
    ethernet_t   ethernet;
    p4calc_t     p4calc;
}

/*
 * All metadata, globally used in the program, also  needs to be assembled
 * into a single struct. As in the case of the headers, we only need to
 * declare the type, but there is no need to instantiate it,
 * because it is done "by the architecture", i.e. outside of P4 functions
 */

struct metadata {
    /* In our case it is empty */
}

/*************************************************************************
 ***********************  P A R S E R  ***********************************
 *************************************************************************/
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            P4CALC_ETYPE : check_p4calc;
            default      : accept;
        }
    }

    state check_p4calc {
        transition select(packet.lookahead<p4calc_t>().p,
        packet.lookahead<p4calc_t>().four,
        packet.lookahead<p4calc_t>().ver) {
            (P4CALC_P, P4CALC_4, P4CALC_VER) : parse_p4calc;
            default                          : accept;
        }
    }

    state parse_p4calc {
        packet.extract(hdr.p4calc);
        transition accept;
    }
}

/*************************************************************************
 ************   C H E C K S U M    V E R I F I C A T I O N   *************
 *************************************************************************/
control MyVerifyChecksum(inout headers hdr,
                         inout metadata meta) {
    apply { }
}

/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action send_back(bit<32> result) {
         bit<48> temp;
         hdr.p4calc.res = result;
         temp = hdr.ethernet.dstAddr;
         hdr.ethernet.dstAddr = hdr.ethernet.srcAddr;
         hdr.ethernet.srcAddr = temp;
         standard_metadata.egress_spec = standard_metadata.ingress_port;
    }

    action computer_turn() {
        /* Check if player 1 wins*/
        if (hdr.p4calc.operand_a == 1 && hdr.p4calc.operand_b == 1 && hdr.p4calc.operand_c == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_d == 1 && hdr.p4calc.operand_e ==1 && hdr.p4calc.operand_f == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_g == 1 && hdr.p4calc.operand_h ==1 && hdr.p4calc.operand_i == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_a == 1 && hdr.p4calc.operand_d ==1 && hdr.p4calc.operand_g == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_b == 1 && hdr.p4calc.operand_e ==1 && hdr.p4calc.operand_h == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_c == 1 && hdr.p4calc.operand_f ==1 && hdr.p4calc.operand_i == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_a == 1 && hdr.p4calc.operand_e ==1 && hdr.p4calc.operand_i == 1) {
        send_back(10);
        }
        else if (hdr.p4calc.operand_c == 1 && hdr.p4calc.operand_e ==1 && hdr.p4calc.operand_g == 1) {
        send_back(10);
        }
        
        
        /*Check if player 2 can win in one move*/
        else if (hdr.p4calc.operand_a == 0 && hdr.p4calc.operand_b == 2 && hdr.p4calc.operand_c == 2) {
        hdr.p4calc.operand_a = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 2 && hdr.p4calc.operand_b == 0 && hdr.p4calc.operand_c == 2) {
        hdr.p4calc.operand_b = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 2 && hdr.p4calc.operand_b == 2 && hdr.p4calc.operand_c == 0) {
        hdr.p4calc.operand_c = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_d == 0 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_f == 2) {
        hdr.p4calc.operand_d = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_d == 2 && hdr.p4calc.operand_e ==0 && hdr.p4calc.operand_f == 2) {
        hdr.p4calc.operand_e = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_d == 2 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_f == 0) {
        hdr.p4calc.operand_f = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_g == 0 && hdr.p4calc.operand_h ==2 && hdr.p4calc.operand_i == 2) {
        hdr.p4calc.operand_g = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_g == 2 && hdr.p4calc.operand_h ==0 && hdr.p4calc.operand_i == 2) {
        hdr.p4calc.operand_h = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_g == 2 && hdr.p4calc.operand_h ==2 && hdr.p4calc.operand_i == 0) {
        hdr.p4calc.operand_i = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 0 && hdr.p4calc.operand_d ==2 && hdr.p4calc.operand_g == 2) {
        hdr.p4calc.operand_a = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 2 && hdr.p4calc.operand_d ==0 && hdr.p4calc.operand_g == 2) {
        hdr.p4calc.operand_d = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 2 && hdr.p4calc.operand_d ==2 && hdr.p4calc.operand_g == 0) {
        hdr.p4calc.operand_g = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_b == 0 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_h == 2) {
        hdr.p4calc.operand_b = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_b == 2 && hdr.p4calc.operand_e ==0 && hdr.p4calc.operand_h == 2) {
        hdr.p4calc.operand_e = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_b == 2 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_h == 0) {
        hdr.p4calc.operand_h = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_c == 0 && hdr.p4calc.operand_f ==2 && hdr.p4calc.operand_i == 2) {
        hdr.p4calc.operand_c = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_c == 2 && hdr.p4calc.operand_f ==0 && hdr.p4calc.operand_i == 2) {
        hdr.p4calc.operand_f = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_c == 2 && hdr.p4calc.operand_f ==2 && hdr.p4calc.operand_i == 0) {
        hdr.p4calc.operand_i = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 0 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_i == 2) {
        hdr.p4calc.operand_a = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 2 && hdr.p4calc.operand_e ==0 && hdr.p4calc.operand_i == 2) {
        hdr.p4calc.operand_e = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_a == 2 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_i == 0) {
        hdr.p4calc.operand_i = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_c == 0 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_g == 2) {
        hdr.p4calc.operand_c = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_c == 2 && hdr.p4calc.operand_e ==0 && hdr.p4calc.operand_g == 2) {
        hdr.p4calc.operand_e = 2;
        send_back(11);
        }
        else if (hdr.p4calc.operand_c == 2 && hdr.p4calc.operand_e ==2 && hdr.p4calc.operand_g == 0) {
        hdr.p4calc.operand_g = 2;
        send_back(11);
        }
        
        
        /*Otherwise make random player 2 move*/
        /*First choice is middle*/
        else if (hdr.p4calc.operand_e == 0) {
        send_back(5);
        }
        /*next choice is corners*/
        else if (hdr.p4calc.operand_a == 0) {
        send_back(1);
        }
        else if (hdr.p4calc.operand_c == 0) {
        send_back(3);
        }
        else if (hdr.p4calc.operand_g == 0) {
        send_back(7);
        }
        else if (hdr.p4calc.operand_i == 0) {
        send_back(9);
        }
        /*last choice is regular edge*/
        else if (hdr.p4calc.operand_b == 0) {
        send_back(2);
        }
        else if (hdr.p4calc.operand_d == 0) {
        send_back(4);
        }
        else if (hdr.p4calc.operand_f == 0) {
        send_back(6);
        }
        else if (hdr.p4calc.operand_h == 0) {
        send_back(8);
        }
        /*if no available moves then it sends back a draw*/
        else {
        send_back(12);
        }
    }


    action operation_drop() {
        mark_to_drop(standard_metadata);
    }

    table calculate {
        key = {
            hdr.p4calc.op        : exact;
        }
        actions = {
            computer_turn;
            operation_drop;
        }
        const default_action = operation_drop();
        const entries = {
            P4CALC_PLUS : computer_turn();
        }
    }

    apply {
        if (hdr.p4calc.isValid()) {
            calculate.apply();
        } else {
            operation_drop();
        }
    }
}

/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

/*************************************************************************
 *************   C H E C K S U M    C O M P U T A T I O N   **************
 *************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

/*************************************************************************
 ***********************  D E P A R S E R  *******************************
 *************************************************************************/
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.p4calc);
    }
}

/*************************************************************************
 ***********************  S W I T T C H **********************************
 *************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
