#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h> 

int main() {
    char op_name; 
    int a, b;
    char lib_path;


    while (scanf("%s %d %d", op_name, &a, &b) == 3) {
        
        
        sprintf(lib_path, "./lib%s.so", op_name);

    
        void *lib_handle = dlopen(lib_path, RTLD_LAZY);
        if (lib_handle == NULL) {
           
            continue; 
        }

     
        int (*target_func)(int, int);
        target_func = (int (*)(int, int)) dlsym(lib_handle, op_name);

        
        if (target_func != NULL) {
            int ans = target_func(a, b);
            printf("%d\n", ans);
        }

      
        dlclose(lib_handle);
    }

    return 0;
}
