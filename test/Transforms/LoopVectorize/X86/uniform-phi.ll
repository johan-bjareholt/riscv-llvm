; RUN: opt < %s  -loop-vectorize -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7 -debug-only=loop-vectorize -S 2>&1 | FileCheck %s
; REQUIRES: asserts
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; CHECK-LABEL: test
; CHECK-DAG: LV: Found uniform instruction:   %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
; CHECK-DAG: LV: Found uniform instruction:   %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
; CHECK-DAG: LV: Found uniform instruction:   %exitcond = icmp eq i64 %indvars.iv, 1599

define void @test(float* noalias nocapture %a, float* noalias nocapture readonly %b) #0 {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds float, float* %b, i64 %indvars.iv
  %tmp0 = load float, float* %arrayidx, align 4
  %add = fadd float %tmp0, 1.000000e+00
  %arrayidx5 = getelementptr inbounds float, float* %a, i64 %indvars.iv
  store float %add, float* %arrayidx5, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv, 1599
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  ret void
}

; CHECK-LABEL: foo
; CHECK-DAG: LV: Found uniform instruction:   %cond = icmp eq i64 %i.next, %n
; CHECK-DAG: LV: Found uniform instruction:   %tmp1 = getelementptr inbounds i32, i32* %a, i32 %tmp0
; CHECK-NOT: LV: Found uniform instruction:   %i = phi i64 [ %i.next, %for.body ], [ 0, %entry ]

define void @foo(i32* %a, i64 %n) {
entry:
  br label %for.body

for.body:
  %i = phi i64 [ %i.next, %for.body ], [ 0, %entry ]
  %tmp0 = trunc i64 %i to i32
  %tmp1 = getelementptr inbounds i32, i32* %a, i32 %tmp0
  store i32 %tmp0, i32* %tmp1, align 4
  %i.next = add nuw nsw i64 %i, 1
  %cond = icmp eq i64 %i.next, %n
  br i1 %cond, label %for.end, label %for.body

for.end:
  ret void
}
