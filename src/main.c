#include "Colon.h"
#include "DetermineSize.h"
#include "GetAndSet.h"
#include "Print.h"
#include "Subsets.h"
#include "VectorManager.h"

// User would write v4 = v1 + v2[v3[2]] + 3.3
void EXPR1(VectorManager *vm) {
  int vars_in_expr[] = {0, 0};
  int types_of_vars[] = {2, 2};
  int nvars = 2;
  int var_left = 2;
  size_t s = determine_size(vm, vars_in_expr, types_of_vars, nvars);
  alloc_temp_numeric(s, vm);
  for (size_t i = 0; i < s; i++) {
    vm->tempNum->data[i] = get_num(i, 0, vm) + get_num(i, 1, vm);
  }
  if (s > vm->numerics[var_left].size) {
    alloc_numeric(var_left, s, vm);
  }
  for (size_t i = 0; i < s; i++) {
    *set_num(i, var_left, vm) = vm->tempNum->data[i];
  }
}

int main() {
  VectorManager vm = create_vm();
  add_numerics(4, &vm);
  double scalarNums[3] = {3.14};
  vm.scalarNums = scalarNums;

  alloc_numeric(0, 5, &vm);
  alloc_numeric(1, 5, &vm);
  alloc_numeric(2, 5, &vm);

  colon_numeric(0, 1, 5, &vm);
  colon_numeric(1, 6, 10, &vm);
  colon_numeric(2, 1, 5, &vm);

  print_numeric(0, &vm);
  print_numeric(1, &vm);
  print_numeric(2, &vm);

  EXPR1(&vm);
  print_numeric(2, &vm);

  free_vm(&vm);
}
