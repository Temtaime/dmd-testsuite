/*
PERMUTE_ARGS:
LDC: just a different error msg
DISABLED: LDC
REQUIRED_ARGS: -Xi=UNKNOWN_FIELD_NAME
TEST_OUTPUT:
---
Error: unknown JSON field `-Xi=UNKNOWN_FIELD_NAME`, expected one of `compilerInfo`, `buildInfo`, `modules`, `semantics`
       run `dmd` to print the compiler manual
       run `dmd -man` to open browser on manual
---
*/
