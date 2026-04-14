.globl make_node
.globl insert
.globl get
.globl getAtMost


# struct Node* make_node(int val)

make_node:
    # sp adjust kar rahe so that variables udd na jaye
    addi sp, sp, -16
    sd ra, 8(sp)
    sw a0, 4(sp)       # apna value save phle

    # 24 bytes ka malloc cz 64-bit mei pointers 8 byte ke hote hain,
    li a0, 24          
    call malloc

    # struct setup 
    lw t0, 4(sp)       
    sw t0, 0(a0)       # node->val mei daal diya
    sd zero, 8(a0)     # both child pointers null
    sd zero, 16(a0)    

    # sab restore karke wapas 
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

# struct Node* insert(struct Node* root, int val)

insert:
    # root null ie new node 
    bnez a0, .L_insert_rec
    mv a0, a1          # make_node call karne ke liye a0 me daalo
    j make_node        

.L_insert_rec:
    
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)      # s0 me apna root safe rahega
    sw s1, 12(sp)      # s1 me value hai

    mv s0, a0          
    mv s1, a1          

    lw t0, 0(s0)       # check current node
    
    
    bge a1, t0, .L_insert_right  

.L_insert_left:
    ld a0, 8(s0)       # left side jao
    mv a1, s1          
    call insert
    sd a0, 8(s0)       #new root on left
    j .L_insert_done

.L_insert_right:
    ld a0, 16(s0)      # right side jao
    mv a1, s1          
    call insert
    sd a0, 16(s0)      # ew root in right

.L_insert_done:
    mv a0, s0          # return root as usual
    
    lw s1, 12(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

# struct Node* get(struct Node* root, int val)

get:
   
.L_get_loop:
    beqz a0, .L_get_end         # dead end, return null
    lw t0, 0(a0)                
    beq a1, t0, .L_get_end      # found
    
    blt a1, t0, .L_get_left     # agar chota hai toh left jayenge

.L_get_right:
    ld a0, 16(a0)               # root = root->right  logic
    j .L_get_loop

.L_get_left:
    ld a0, 8(a0)                # root = root->left
    j .L_get_loop

.L_get_end:
    ret


# int getAtMost(int val, struct Node* root)

getAtMost:
    li t1, -1                   # max_so_far ko -1 le lete hain start me

.L_gam_loop:
    beqz a1, .L_gam_end         # tree khatam 
    lw t0, 0(a1)                

    bgt t0, a0, .L_gam_left     # current value zyaada badi hai, left me jake choti dhundo

   
    mv t1, t0                   # update current best answer
    beq t0, a0, .L_gam_end     
    
    ld a1, 16(a1)               # try karte hain ki isse bada kuch mile right me
    j .L_gam_loop

.L_gam_left:
    ld a1, 8(a1)                # go left
    j .L_gam_loop

.L_gam_end:
    mv a0, t1                   # final answer return ho raha
    ret
