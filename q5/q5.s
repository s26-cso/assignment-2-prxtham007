.data
file_name: .string "input.txt"
read_mode: .string "r"
ans_yes:   .string "Yes\n"
ans_no:    .string "No\n"

    .text
    .globl main

main:
   
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s1, 32(sp)
    sd s2, 24(sp)
    sd s3, 16(sp)
    sd s4, 8(sp)

  
    la a0, file_name
    la a1, read_mode
    call fopen
    mv s1, a0          

    mv a0, s1
    li a1, 0
    li a2, 2           
    call fseek

    mv a0, s1
    call ftell
    mv s3, a0          
    addi s3, s3, -1    

   
    mv a0, s1
    mv a1, s3
    li a2, 0           
    call fseek
    mv a0, s1
    call fgetc
    li t1, 10          # '\n' ascii
    bne a0, t1, setup_loop
    addi s3, s3, -1    

setup_loop:
    li s2, 0           

check_pali_loop:
    bge s2, s3, print_yes   

    mv a0, s1
    mv a1, s2
    li a2, 0
    call fseek
    mv a0, s1
    call fgetc
    mv s4, a0          

    mv a0, s1
    mv a1, s3
    li a2, 0
    call fseek
    mv a0, s1
    call fgetc


    bne s4, a0, print_no

    addi s2, s2, 1
    addi s3, s3, -1
    j check_pali_loop

print_yes:
    la a0, ans_yes
    call printf
    j cleanup

print_no:
    la a0, ans_no
    call printf

cleanup:
    mv a0, s1
    call fclose

    
    ld ra, 40(sp)
    ld s1, 32(sp)
    ld s2, 24(sp)
    ld s3, 16(sp)
    ld s4, 8(sp)
    addi sp, sp, 48
    li a0, 0
    ret
