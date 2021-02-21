#ifndef INFO_H_HEADER_
#define INFO_H_HEADER_

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

typedef struct var var;
typedef struct func func;
typedef struct var_list var_list;
typedef struct func_list func_list;


struct var{
        char var_name[50];
        char var_type[10];
        int var_scope;
	int var_value;
        struct var* next;
};

struct func{
        char func_name[50];
        int arg_num;
        char arg_type[4][10];
        char ret_type[10];
        struct func * next;
};

struct var_list{
        var* head;
        var* tail;
};

struct func_list{
        func* head;
        func* tail;
};

var_list* init_var_list();
func_list* init_func_list();

void free_var_list(var_list * ptr);
void free_func_list(func_list * ptr);

var * find_var_list(var_list * ptr, char* name);
func * find_func_list(func_list * ptr, char* name);

var_list* free_scope(var_list * ptr, int num);

void push_var_list(var_list * ptr, char * name, char * type, int scope, int value);
void push_func_list(func_list * ptr, char * name, int num, char type[4][10], char* ret_type);

void update_var_val(var_list * ptr, char * name, int value);

void print_var_list(var_list * ptr);
void print_func_list(func_list * ptr);

#endif
