#include "LinkedList.h"

var_list* init_var_list(){
	var_list * ptr = malloc(sizeof(struct var));
	ptr->head = NULL;
	ptr->tail = NULL;
}

func_list* init_func_list(){
	func_list * ptr = malloc(sizeof(struct func));
	ptr->head = NULL;
	ptr->tail = NULL;
}

void free_var_list(var_list * ptr){
	while(ptr->head != NULL){
		var * tmp = ptr->head;
		ptr->head = ptr->head->next;
		free(ptr);
	}
}

void free_func_list(func_list * ptr){
	while(ptr->head != NULL){
		func * tmp = ptr->head;
		ptr->head = ptr->head->next;
		free(ptr);
	}
}

var * find_var_list(var_list * ptr, char* name){
	var * tmp = ptr->head;
	while(tmp != NULL && strcmp(tmp->var_name, name) != 0)
		tmp = tmp->next;
	return tmp;
}

func * find_func_list(func_list * ptr, char* name){
	func * tmp = ptr->head;
	while(tmp != NULL && strcmp(tmp->func_name, name) != 0)
		tmp = tmp->next;
	return tmp;
}

var_list* free_scope(var_list * ptr, int num){
	var * prv = NULL, * itr;
	for(itr = ptr->head; itr!=NULL;){
		if(itr->var_scope == num){
			if(itr == ptr->head){
				ptr->head = itr->next;
				prv = itr;
				itr = itr->next;
				free(prv);
			}
			else{
				prv->next = itr->next;
				free(itr);
				itr = prv->next;
			}
		}
		else{
			prv = itr;
			itr = itr->next;
		}
	}
	if(ptr->head == NULL)
		ptr->tail = NULL;
	else{
		for(itr = ptr->head; itr->next != NULL ; itr = itr->next);
		ptr->tail = itr;
	}
	return ptr;
}


void push_var_list(var_list * ptr, char * name, char * type, int scope, int value){
	var * tmp = malloc(sizeof(struct var));
	strcpy(tmp->var_name, name);
	strcpy(tmp->var_type, type);
	tmp->var_scope = scope;
	tmp->var_value = value;
	tmp->next = NULL;
	if(ptr->head == NULL){
		ptr->head = tmp;
		ptr->tail = tmp;
	}
	else{
		var * itr = ptr->tail;
		itr->next = tmp;
		ptr->tail = tmp;
	}
}

void push_func_list(func_list * ptr, char * name, int num, char type[4][10], char* ret_type){
	func * tmp = malloc(sizeof(struct func));
	strcpy(tmp->func_name, name);
	tmp->arg_num = num;
	for(int i = 0; i< 4; i++)
		strcpy(tmp->arg_type[i], type[i]);
	//strcpy(tmp->arg_type, type);
	strcpy(tmp->ret_type, ret_type);
	tmp->next = NULL;
	if(ptr->head == NULL){
		ptr->head = tmp;
		ptr->tail = tmp;
	}
	else{
		func * itr = ptr->tail;
		itr->next = tmp;
		ptr->tail = tmp;
	}
}
void update_var_val(var_list * ptr, char * name, int value){
	var * tmp = ptr->head;
        while(tmp != NULL && strcmp(tmp->var_name, name) != 0)
                tmp = tmp->next;
        tmp->var_value = value;
}
void print_var_list(var_list * ptr){
	var * itr = ptr->head;
	while(itr != NULL)
	{
		printf("var: name: %s, type: %s, scope: %d\n", itr->var_name, itr->var_type, itr->var_scope);
		itr = itr->next;
	}
	printf("**************************\n");
}
void print_func_list(func_list * ptr){
	func * itr = ptr->head;
	while(itr != NULL)
	{
		printf("func: name: %s, number: %d, type0: %s, type1: %s, type2: %s, type3: %s, ret_type: %s\n", itr->func_name, itr->arg_num, itr->arg_type[0], itr->arg_type[1], itr->arg_type[2], itr->arg_type[3], itr->ret_type);
		itr = itr->next;
	}
	printf("**************************\n");
}
