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

    action user_win() {
        send_back(10);
    }


    action operation_drop() {
        mark_to_drop(standard_metadata);
    }

    table calculate {
        key = {
            hdr.p4calc.operand_a        : exact;
            hdr.p4calc.operand_b        : exact;
            hdr.p4calc.operand_c        : exact;
            hdr.p4calc.operand_d        : exact;
            hdr.p4calc.operand_e        : exact;
            hdr.p4calc.operand_f        : exact;
            hdr.p4calc.operand_g        : exact;
            hdr.p4calc.operand_h        : exact;
            hdr.p4calc.operand_i        : exact;
        }
        actions = {
            user_win;
            operation_drop;
        }
        const default_action = operation_drop();
        const entries = {
            {1,1,1,0,0,0,0,0,0} : user_win();
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
