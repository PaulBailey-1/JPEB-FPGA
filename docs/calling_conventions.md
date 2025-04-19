# Calling Conventions

The bcc compiler uses `r1` as the stack pointer and `r2` as the base pointer, so they are callee-saved.  
Everything else is caller saved.

When the compiler calls a function, it places the return address in `r7`.  
If your function plans to return to the caller, it should be careful to not lose this value.

If you keep the return address in `r7`, you can return to the caller with `jalr r7, r7`

For function calls, The compiler passes in the first 4 arguments in `r3`, `r4`, `r5`, and `r6`, in that order.  
Remaining arguments are passed on the stack.

Return values should be placed in `r3`.