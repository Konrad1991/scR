#include "VectorManager.h"

#ifndef SUBSETS_H
#define SUBSETS_H

void free_subsets(VectorManager *vm);
void init_numeric_subset(SubsetNumeric *v);
void init_integer_subset(SubsetInteger *v);
void init_logical_subset(SubsetLogical *v);
void add_numeric_subsets(size_t n, VectorManager *vm);
void add_integer_subsets(size_t n, VectorManager *vm);
void add_logical_subsets(size_t n, VectorManager *vm);
SubsetNumeric *s_n_w_d_s(size_t subset_vec_index, size_t vec_index, double idx,
                         VectorManager *vm);
SubsetNumeric *s_n_w_s_n(size_t subset_vec_index, size_t vec_index,
                         SubsetNumeric *sn, VectorManager *vm);
double get_num_sub(size_t index, size_t vec_index, VectorManager *vm);

// ALternative:
typedef struct {
  Numeric *vec;
  size_t index;
} NumSub;

double subset_nv_with_nv(size_t subsetted_vec, size_t vec_in_brackets,
                         size_t index, VectorManager *vm);

double subset_nv_with_ns(size_t subsetted_vec, double sub_index, size_t index,
                         VectorManager *vm);

#endif

/*
            Var1         Var2
1        num_vec      num_vec
2        int_vec      num_vec
3        log_vec      num_vec
4   num_vec_robj      num_vec
5   int_vec_robj      num_vec
6   log_vec_robj      num_vec
7       scal_num      num_vec
8       scal_int      num_vec
9       scal_log      num_vec
10   num_literal      num_vec
11   int_literal      num_vec
12   log_literal      num_vec
13       num_vec      int_vec
14       int_vec      int_vec
15       log_vec      int_vec
16  num_vec_robj      int_vec
17  int_vec_robj      int_vec
18  log_vec_robj      int_vec
19      scal_num      int_vec
20      scal_int      int_vec
21      scal_log      int_vec
22   num_literal      int_vec
23   int_literal      int_vec
24   log_literal      int_vec
25       num_vec      log_vec
26       int_vec      log_vec
27       log_vec      log_vec
28  num_vec_robj      log_vec
29  int_vec_robj      log_vec
30  log_vec_robj      log_vec
31      scal_num      log_vec
32      scal_int      log_vec
33      scal_log      log_vec
34   num_literal      log_vec
35   int_literal      log_vec
36   log_literal      log_vec
37       num_vec num_vec_robj
38       int_vec num_vec_robj
39       log_vec num_vec_robj
40  num_vec_robj num_vec_robj
41  int_vec_robj num_vec_robj
42  log_vec_robj num_vec_robj
43      scal_num num_vec_robj
44      scal_int num_vec_robj
45      scal_log num_vec_robj
46   num_literal num_vec_robj
47   int_literal num_vec_robj
48   log_literal num_vec_robj
49       num_vec int_vec_robj
50       int_vec int_vec_robj
51       log_vec int_vec_robj
52  num_vec_robj int_vec_robj
53  int_vec_robj int_vec_robj
54  log_vec_robj int_vec_robj
55      scal_num int_vec_robj
56      scal_int int_vec_robj
57      scal_log int_vec_robj
58   num_literal int_vec_robj
59   int_literal int_vec_robj
60   log_literal int_vec_robj
61       num_vec log_vec_robj
62       int_vec log_vec_robj
63       log_vec log_vec_robj
64  num_vec_robj log_vec_robj
65  int_vec_robj log_vec_robj
66  log_vec_robj log_vec_robj
67      scal_num log_vec_robj
68      scal_int log_vec_robj
69      scal_log log_vec_robj
70   num_literal log_vec_robj
71   int_literal log_vec_robj
72   log_literal log_vec_robj
73       num_vec     scal_num
74       int_vec     scal_num
75       log_vec     scal_num
76  num_vec_robj     scal_num
77  int_vec_robj     scal_num
78  log_vec_robj     scal_num
79      scal_num     scal_num
80      scal_int     scal_num
81      scal_log     scal_num
82   num_literal     scal_num
83   int_literal     scal_num
84   log_literal     scal_num
85       num_vec     scal_int
86       int_vec     scal_int
87       log_vec     scal_int
88  num_vec_robj     scal_int
89  int_vec_robj     scal_int
90  log_vec_robj     scal_int
91      scal_num     scal_int
92      scal_int     scal_int
93      scal_log     scal_int
94   num_literal     scal_int
95   int_literal     scal_int
96   log_literal     scal_int
97       num_vec     scal_log
98       int_vec     scal_log
99       log_vec     scal_log
100 num_vec_robj     scal_log
101 int_vec_robj     scal_log
102 log_vec_robj     scal_log
103     scal_num     scal_log
104     scal_int     scal_log
105     scal_log     scal_log
106  num_literal     scal_log
107  int_literal     scal_log
108  log_literal     scal_log
109      num_vec  num_literal
110      int_vec  num_literal
111      log_vec  num_literal
112 num_vec_robj  num_literal
113 int_vec_robj  num_literal
114 log_vec_robj  num_literal
115     scal_num  num_literal
116     scal_int  num_literal
117     scal_log  num_literal
118  num_literal  num_literal
119  int_literal  num_literal
120  log_literal  num_literal
121      num_vec  int_literal
122      int_vec  int_literal
123      log_vec  int_literal
124 num_vec_robj  int_literal
125 int_vec_robj  int_literal
126 log_vec_robj  int_literal
127     scal_num  int_literal
128     scal_int  int_literal
129     scal_log  int_literal
130  num_literal  int_literal
131  int_literal  int_literal
132  log_literal  int_literal
133      num_vec  log_literal
134      int_vec  log_literal
135      log_vec  log_literal
136 num_vec_robj  log_literal
137 int_vec_robj  log_literal
138 log_vec_robj  log_literal
139     scal_num  log_literal
140     scal_int  log_literal
141     scal_log  log_literal
142  num_literal  log_literal
143  int_literal  log_literal
144  log_literal  log_literal
*/
