(module tests mzscheme
  
  (provide test-list)
  ;;;;;;;;;;;;;;;; tests ;;;;;;;;;;;;;;;;
  
  (define test-list
    '(
  
      ;; simple arithmetic
      (positive-const "11" 11)
      (negative-const "-33" -33)
      (simple-arith-1 "-(44,33)" 11)
  
      ;; nested arithmetic
      (nested-arith-left "-(-(44,33),22)" -11)
      (nested-arith-right "-(55, -(22,11))" 44)
  
      ;; simple variables
      (test-var-1 "x" 10)
      (test-var-2 "-(x,1)" 9)
      (test-var-3 "-(1,x)" -9)
      
      ;; simple unbound variables
      (test-unbound-var-1 "foo" error)
      (test-unbound-var-2 "-(x,foo)" error)
  
      ;; simple conditionals
      (if-true "if zero?(0) then 3 else 4" 3)
      (if-false "if zero?(1) then 3 else 4" 4)
      
      ;; test dynamic typechecking
      (no-bool-to-diff-1 "-(zero?(0),1)" error)
      (no-bool-to-diff-2 "-(1,zero?(0))" error)
      (no-int-to-if "if 1 then 2 else 3" error)

      ;; make sure that the test and both arms get evaluated
      ;; properly. 
      (if-eval-test-true "if zero?(-(11,11)) then 3 else 4" 3)
      (if-eval-test-false "if zero?(-(11, 12)) then 3 else 4" 4)
      
      ;; and make sure the other arm doesn't get evaluated.
      (if-eval-test-true-2 "if zero?(-(11, 11)) then 3 else foo" 3)
      (if-eval-test-false-2 "if zero?(-(11,12)) then foo else 4" 4)

      ;; simple let
      (simple-let-1 "let x = 3 in x" 3)

      ;; make sure the body and rhs get evaluated
      (eval-let-body "let x = 3 in -(x,1)" 2)
      (eval-let-rhs "let x = -(4,1) in -(x,1)" 2)

      ;; check nested let and shadowing
      (simple-nested-let "let x = 3 in let y = 4 in -(x,y)" -1)
      (check-shadowing-in-body "let x = 3 in let x = 4 in x" 4)
      (check-shadowing-in-rhs "let x = 3 in let x = -(x,1) in x" 2)

      ;; simple applications
      (apply-proc-in-rator-pos "(proc(x) -(x,1)  30)" 29)
      (apply-simple-proc "let f = proc (x) -(x,1) in (f 30)" 29)
      (let-to-proc-1 "(proc(f)(f 30)  proc(x)-(x,1))" 29)


      (nested-procs "((proc (x) proc (y) -(x,y)  5) 6)" -1)
      (nested-procs2 "let f = proc(x) proc (y) -(x,y) in ((f -(10,5)) 6)"
        -1)
      
       (y-combinator-1 "
let fix =  proc (f)
            let d = proc (x) proc (z) ((f (x x)) z)
            in proc (n) ((f (d d)) n)
in let
    t4m = proc (f) proc(x) if zero?(x) then 0 else -((f -(x,1)),-4)
in let times4 = (fix t4m)
   in (times4 3)" 12)
      
       ;; simple letrecs
      (simple-letrec-1 "letrec f(x) = -(x,1) in (f 33)" 32)
      (simple-letrec-2
        "letrec f(x) = if zero?(x)  then 0 else -((f -(x,1)), -2) in (f 4)"
        8)

      (simple-letrec-3
        "let m = -5 
 in letrec f(x) = if zero?(x) then 0 else -((f -(x,1)), m) in (f 4)"
        20)
      
;      (fact-of-6  "letrec
;  fact(x) = if zero?(x) then 1 else *(x, (fact sub1(x)))
;in (fact 6)" 
;                  720)
      
      (HO-nested-letrecs
"letrec even(odd)  = proc(x) if zero?(x) then 1 else (odd -(x,1))
   in letrec  odd(x)  = if zero?(x) then 0 else ((even odd) -(x,1))
   in (odd 13)" 1)

      
      (begin-test-1
        "begin 1; 2; 3 end"
        3)

      (gensym-test-1 
"let g = let counter = newref(0) 
         in proc (dummy) let d = setref(counter, -(deref(counter),-1))
                    in deref(counter)
in -((g 11),(g 22))"
       -1)

      (simple-store-test-1 "let x = newref(17) in deref(x)" 17)

      (assignment-test-1 "let x = newref(17) 
                          in begin setref(x,27); deref(x) end"
        27)

      (gensym-test-2 
"let g = let counter = newref(0) 
         in proc (dummy) begin
                           setref(counter, -(deref(counter),-1));
                           deref(counter)
                         end
 in -((g 11),(g 22))"
       -1)

     (even-odd-via-set-1 "
let x = newref(0)
in letrec even(d) = if zero?(deref(x)) 
                   then 1
                   else let d = setref(x, -(deref(x),1))
                        in (odd d)
          odd(d)  = if zero?(deref(x)) 
                   then 0
                   else let d = setref(x, -(deref(x),1))
                        in (even d)
   in let d = setref(x,13) in (odd -100)" 1)

 (even-odd-via-set-1 "
let x = newref(0)
in letrec even(d) = if zero?(deref(x)) 
                   then 1
                   else let d = setref(x, -(deref(x),1))
                        in (odd d)
          odd(d)  = if zero?(deref(x)) 
                   then 0
                   else let d = setref(x, -(deref(x),1))
                        in (even d)
   in let d = setref(x,13) in (odd -100)" 1)

 (show-allocation-1 "
let x = newref(22)
in let f = proc (z) let zz = newref(-(z,deref(x))) in deref(zz)
   in -((f 66), (f 55))"
   11)

 (chains-1 "
let x = newref(newref(0))
in begin 
    setref(deref(x), 11);
    deref(deref(x))
   end"
   11)

      ; ==================== Array test cases =========================

   (array-detailed-test-1 "let a = newarray(2, -99) in
                              let p = proc (x)
                                  let v = read-array(x, 1)
                                  in update-array(x, 1, -(v, -1))
                       in begin update-array(a, 1, 0); (p a); (p a); read-array(a, 1) end"
                      2)

      (array-detailed-test-2 "let a = newarray(3, 5) in
                              let p = proc (x)
                                   let v = read-array(x, 1)
                                   in update-array(x, 1, -(-2, v))
                              in let q = proc(x)
                                  let v1 = read-array(x, 1) in 
                                  let v2 = read-array(x, 2)    
                                  in update-array(x, 1, -(v2, -(0, v1)))
                       in begin update-array(a, 1, -5); (p a); (q a); read-array(a, 1) end"
                      8)

      (array-detailed-test-3 "let a = newarray(2, -99) in
                              let p = proc (x)
                                  let v = read-array(x, 1)
                                  in update-array(v, 1, -(read-array(v, 2), -(-1, read-array(v, 1))))
                       in begin update-array(a, 1, newarray(3,4)); (p a); (p a); (p a); read-array(read-array(a, 1), 1) end"
                      19)


      (array-detailed-test-4 "let a = newarray(5, -99) in
                               let v = copy-array(a)
                                  in begin
                                     update-array(a, 0, 1); update-array(a, 1, 2); update-array(a, 2, 3); update-array(a, 3, 4);
                                     -(-(0, read-array(v, 0)), read-array(v, 1))         
                                  end"
                      198)

      (array-detailed-test-5 "let a = newarray(5, 1) in
                                  begin
                                     update-array(a, 0, 0); update-array(a, 1, 1); update-array(a, 2, 2); update-array(a, 3, 3);
                                     swap-array(a, 0, 3);
                                     -(read-array(a, 0), read-array(a,1))
                                  end"
                      2)
;
      (array-detailed-test-6 "let a = newarray(101, 45) in
                                let b = newarray(56, 34) in
                                    -(length-array(b), -(0, length-array(a)))"
                      157)

      (array-detailed-test-7 "let a = newarray(89, 78) in
                                let b = copy-array(a) in
                                    length-array(b)"
                      89)

      (array-detailed-test-8 "let a = newarray(89, 78) in
                                let b = copy-array(a) in
                                    begin
                                    update-array(b, 0, 5); swap-array(b, 0, 1); -(length-array(a), -(0, read-array(b, 1)))
                                    end"
                      94)

 
;            ; ==================== Queue test cases =========================;
;
      (queue-test1 "let x = newqueue() in begin enqueue(x, 10); enqueue(x, 20); enqueue(x,30); queue-size(x) end" 3)
      (queue-test2 "let x = newqueue() in begin enqueue(x, 10); enqueue(x, 20); dequeue(x); dequeue(x); enqueue(x, 30); peek(x) end" 30)
      (queue-test3 "let x = newqueue() in begin enqueue(x, 10); enqueue(x, 20); enqueue(x,30); dequeue(x); dequeue(x); dequeue(x); empty-queue?(x) end" #t)
      (queue-test4 "let x = newqueue() in begin enqueue(x, 10); dequeue(x); enqueue(x, 20); enqueue(x, 30); dequeue(x); peek(x) end" 30)
      (queue-test5 "let x = newqueue() in begin enqueue(x, 10); dequeue(x); enqueue(x, 20); enqueue(x, 30); dequeue(x); peek(x); enqueue(x, 30); queue-size(x) end" 2)
      (queue-test6 "let x = newqueue() in let y= newqueue() in begin enqueue(x, 10); dequeue(x); enqueue(x, 20); enqueue(x, 30); dequeue(x); peek(x); enqueue(y, 50); enqueue(y, 18); enqueue(y, 26); enqueue(x, 10); enqueue(x, 50); queue-size(y) end" 3)
      (queue-test6 "let x = newqueue() in let y= newqueue() in begin enqueue(x, 10); dequeue(x); enqueue(x, 20); enqueue(x, 30); dequeue(x); peek(x); enqueue(y, 50); enqueue(y, 18); enqueue(y, 26); enqueue(x, 10);  dequeue(y); enqueue(x, 50); peek(y) end" 18)
  
;;;;;;;;; Run this test case by yourself otherwise it will give an error since return value is unspecified for print-queue. It should print 30 50.
;      (queue-test7 "let x = newqueue() in begin enqueue(x, 10); dequeue(x); enqueue(x, 20); enqueue(x, 30); dequeue(x); peek(x); enqueue(x, 50); print-queue(x) end")
;      
;
;           ; ==================== Map test cases =========================;
      (map-simple-test "read-array(map((x -> -(2, 1)) in newarray(4,2)),1)" 1)  

      (map-simple-test-2 "let x = newarray(4, 2) in                               
                                 begin
                                   update-array(x, 0, 0);
                                   update-array(x, 1, 1);
                                   update-array(x, 2, 2);
                                   update-array(x, 3, 3);
                                   read-array(map((y -> -(y, 1)) in x), 0)
                                 end" -1)
 
;     
;                             
; 
;
;
;
 ))
  )
