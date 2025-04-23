#include "Vjpeb.h"
#include "verilated.h"

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Vjpeb* top = new Vjpeb;

    for (int i = 0; i < 1000; i++) {
        top->eval();
    }

    delete top;
    return 0;
}
