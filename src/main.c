#include "Colon.h"
#include "DetermineSize.h"
#include "GetAndSet.h"
#include "Print.h"
#include "Subsets.h"
#include "VectorManager.h"

// User would write v4 = v1 + v2[v3[2]] + 3.3
void EXPR1(VectorManager *vm) {

  // Calculation of subset v2[v3[2]]
  add_numeric_subsets(1, vm);
  // Variables: v3 = 1:5; v2 = 6:10; v3[2] = 3; v2[3] = 9
  s_n_w_s_n(0, 1, s_n_w_d_s(0, 2, 2.0, vm), vm);

  // Add r obj
  add_numerics_robjs(1, vm);

  int vars_in_expr[] = {0, 0};
  int types_of_vars[] = {2, 3};
  int nvars = 2;
  int var_left = 2;
  size_t s = determine_size(vm, vars_in_expr, types_of_vars, nvars);
  alloc_temp_numeric(s, vm);
  for (size_t i = 0; i < s; i++) {
    printf(
        "Vec1: %f \t; Vec3[2]: %f \t; Vec2[Vec3[2]]: %f \t; Vec3[Vec1 + "
        "Vec2]: %f \t; Vec1[Vec2]: %f \t; first scalar: %f\n",
        get_num(i, 0, vm), subset_nv_with_ns(2, 2.0, i, vm),
        subset_nv_with_ns(0, subset_nv_with_ns(2, 2.0, i, vm), i, vm),
        subset_nv_with_ns(
            0,
            subset_nv_with_ns(2, get_num(i, 0, vm) * get_num(i, 1, vm), i, vm),
            i, vm),
        subset_nv_with_nv(0, 1, i, vm), get_scalar_num(0, vm));
    vm->tempNum->data[i] =
        get_num(i, 0, vm) +
        subset_nv_with_ns(0, subset_nv_with_ns(2, 2.0, i, vm), i, vm) +
        subset_nv_with_ns(
            0,
            subset_nv_with_ns(2, get_num(i, 0, vm) * get_num(i, 1, vm), i, vm),
            i, vm) +
        subset_nv_with_nv(0, 1, i, vm) + get_scalar_num(0, vm);
  }
  if (s > vm->numerics[var_left].size) {
    alloc_numeric(var_left, s, vm);
  }

  for (size_t i = 0; i < s; i++) {
    // TODO: add break for set_scalar after first assignment
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

  EXPR1(&vm);
  print_numeric(2, &vm);

  free_vm(&vm);
}
