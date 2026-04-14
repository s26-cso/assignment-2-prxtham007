.data
format_str: .string "%d "
newline_str: .string "\n"

    .text
    .globl main


# int main(int argc, char** argv)

main:
    # Prologue - saving saare s-registers taaki malloc/printf inko udaye na
    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)       # argc
    sd s1, 56(sp)       # argv
    sd s2, 48(sp)       # arr pointer
    sd s3, 40(sp)       # result pointer
    sd s4, 32(sp)       # stack pointer (array)
    sd s5, 24(sp)       # hamara custom stack size counter
    sd s6, 16(sp)       # main loop counter (i)
    sd s7, 8(sp)        # secondary loop counter

    mv s0, a0           # s0 = argc
    mv s1, a1           # s1 = argv

    # agar array size hi 0 hai (mtlb no args except ./a.out), exit 
    addi s0, s0, -1     # n = argc - 1
    blez s0, end_safely

    # 1. Memory Allocation: malloc(n * 4) kyuki 32-bit int use karenge
    # s0 me 'n' hai. n * 4 ke liye shift left by 2
    slli a0, s0, 2      
    call malloc
    mv s2, a0           # s2 me 'arr' ka address aagaya

    slli a0, s0, 2
    call malloc
    mv s3, a0           # s3 me 'result' ka address 

    slli a0, s0, 2
    call malloc
    mv s4, a0           # s4 me 'stack' ka address

    # 2. Result array ko -1 se initialize karna hai
    li s7, 0            # j = 0
    li t1, -1           # default value
init_res_loop:
    bge s7, s0, start_parsing
    slli t2, s7, 2      # offset = j * 4
    add t3, s3, t2      # t3 = result + (j * 4)
    sw t1, 0(t3)        # result[j] = -1
    addi s7, s7, 1
    j init_res_loop

start_parsing:
    # 3. argv strings ko int me convert karke arr me daalna (atoi call karke)
    li s7, 0            # wapas j = 0
read_args_loop:
    bge s7, s0, main_logic_shuru
    
    # argv pointers 64-bit hote hain, isliye shift by 3 (multiply by 8)
    addi t1, s7, 1      # index j+1 (kyuki argv toh ./a.out hai)
    slli t1, t1, 3
    add t2, s1, t1
    ld a0, 0(t2)        # a0 = argv[j+1]
    
    call atoi           # atoi(argv[j+1])
    
    # atoi returns int in a0. Store it in arr[j] (4-byte words, shift by 2)
    slli t1, s7, 2
    add t2, s2, t1
    sw a0, 0(t2)        # arr[j] = converted_int
    
    addi s7, s7, 1
    j read_args_loop

main_logic_shuru:
    # 4. Asli algorithm (Next Greater Element)
    li s5, 0            # s5 = current stack size (top of stack is s5 - 1)
    addi s6, s0, -1     # s6 = i = n - 1 (reverse traverse according to pseudo)

ulta_loop:
    bltz s6, output_print_karo  # i < 0 hua toh loop khatam
    
stack_khali_karo:
    # while(!stack.empty() && arr[stack.top()] <= arr[i]) stack.pop()
    beqz s5, check_result_update    # agar stack empty hai, while break karo
    
    # get stack.top() -> index hai
    addi t0, s5, -1
    slli t1, t0, 2
    add t2, s4, t1
    lw t3, 0(t2)        # t3 = stack.top()
    
    # get arr[stack.top()]
    slli t4, t3, 2
    add t5, s2, t4
    lw t6, 0(t5)        # t6 = arr[stack.top()]
    
    # get arr[i]
    slli t4, s6, 2
    add t5, s2, t4
    lw t4, 0(t5)        # t4 = arr[i]
    
    # condition check: if (arr[stack.top()] > arr[i]) then while loop is done
    bgt t6, t4, check_result_update
    
    # fail hua condition matlab pop karna hai
    addi s5, s5, -1     # pop stack (just decrement size)
    j stack_khali_karo

check_result_update:
    # if (!stack.empty()) result[i] = stack.top()
    beqz s5, push_element_to_stack
    
    # read top again 
    addi t0, s5, -1
    slli t1, t0, 2
    add t2, s4, t1
    lw t3, 0(t2)        # t3 = stack.top()
    
    # store in result[i]
    slli t4, s6, 2
    add t5, s3, t4
    sw t3, 0(t5)        # result[i] = t3

push_element_to_stack:
    # stack.push(i)
    slli t1, s5, 2
    add t2, s4, t1
    sw s6, 0(t2)        # stack[s5] = i
    addi s5, s5, 1      # stack size ++
    
    # i-- for the main reverse loop
    addi s6, s6, -1
    j ulta_loop

output_print_karo:
    # 5. Print out the result array
    li s7, 0            # j = 0
printing_loop:
    bge s7, s0, end_safely
    
    slli t0, s7, 2
    add t1, s3, t0
    lw a1, 0(t1)        # a1 = result[j]
    la a0, format_str   # a0 = "%d "
    call printf
    
    addi s7, s7, 1
    j printing_loop

end_safely:
    # Print a final newline
    la a0, newline_str
    call printf

    # Epilogue and return 0
    li a0, 0
    ld ra, 72(sp)
    ld s0, 64(sp)
    ld s1, 56(sp)
    ld s2, 48(sp)
    ld s3, 40(sp)
    ld s4, 32(sp)
    ld s5, 24(sp)
    ld s6, 16(sp)
    ld s7, 8(sp)
    addi sp, sp, 80
    ret
