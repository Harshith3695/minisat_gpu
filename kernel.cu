#include <iostream>
#define N 1024

namespace GPU_KERNEL{
using namespace std;

	__shared__ int UE_list[N];

	__shared__ int UE_threads[N];

	__device__
	int var_f(int blocker){
		int var_tmp = blocker >> 1;
		return var_tmp;
	}

	__device__
	int sign_f(int blkr){
		int sign_tmp = blkr & 1;
		return sign_tmp;
	}

	__global__
	void propagate_kernel(int *dev_Lit, int *dev_N, int *dev_blockers, int *dev_flags, int *dev_clauses, int *dev_cindex, int *dev_assigns)
	{

		int tid = threadIdx.x;
		if(tid < *dev_N){

			if(tid == 0){
				int p, q;
				for(p=0;p<=(*dev_N);p++){
					UE_list[p] = -2;
					UE_threads[p] = -2;
					if(p == (*dev_N)){
						UE_list[p] = -1;
						UE_threads[p] = -1;
					}
				}
			}

			int value_1 = (dev_assigns[var_f(dev_blockers[tid])]) ^ (sign_f(dev_blockers[tid]));
			if (value_1 == 0){
				dev_flags[tid] = dev_flags[tid] | 32;
				goto kernel_end;}

			int false_lit = *dev_Lit ^ 1;
			if(dev_clauses[dev_cindex[tid]] == false_lit){
				dev_clauses[dev_cindex[tid]] = dev_clauses[dev_cindex[tid] + 1], dev_clauses[dev_cindex[tid] + 1] = false_lit;
				dev_flags[tid] = dev_flags[tid] | 16;}

			int first = dev_clauses[dev_cindex[tid]];

			UE_threads[tid] = tid, UE_list[tid] = first;

//			int cnt = 0;
//			for(int x=0; UE_list[x] != -1; x++){
//				for(int y=x+1; UE_list[y] != -1; y++){
//					while(UE_list[x] != -2){
//						if(UE_list[x] == UE_list[y])
//							cnt++;
//					}
//				}
//			}


			int value_2 = dev_assigns[var_f(first)] ^ sign_f(first);
			if(first != dev_blockers[tid] && value_2 == 0){
				dev_flags[tid] = dev_flags[tid] | 8;
				goto kernel_end;}

			for(int k = 2; dev_clauses[dev_cindex[tid]+k] != -2 ; k++){
				int value_3 = dev_assigns[var_f(dev_clauses[dev_cindex[tid]+k])] ^ sign_f(dev_clauses[dev_cindex[tid]+k]);
				if(value_3 != 1){
					dev_clauses[dev_cindex[tid]+1] = dev_clauses[dev_cindex[tid]+k]; dev_clauses[dev_cindex[tid]+k] = false_lit;
					dev_flags[tid] = dev_flags[tid] | 4;
					goto kernel_end;
				}
			}

			int value_4 = dev_assigns[var_f(first)] ^ sign_f(first);
			if(value_4 == 1){
				dev_flags[tid] = dev_flags[tid] | 2;
			}else{
	 			dev_assigns[var_f(first)] = (sign_f(first));
				dev_flags[tid] = dev_flags[tid] | 1;

				for(int a=0;a<=(*dev_N);a++){
					if(((UE_threads[a] != -2) && (UE_threads[a] != -1)) && (UE_threads[a] == tid)){
						for(int b=0;UE_list[b] != -1;b++){
							printf("UE_list[%d] = %d, Address = %p, tid = %d\n", a, UE_list[b], &UE_list[b], tid);
						}
					}
					break;
				}
			}

			kernel_end:
			__syncthreads();
		}
	}
};



//			if(tid == 0){
//			for(int a=0;a<=(*dev_N);a++){
//				printf("UE_list[%d] = %d, Address = %p\n", a, UE_list[a], &UE_list[a]);
//				printf("UE_threads[%d] = %d, Address = %p\n", a, UE_threads[a], &UE_threads[a]);
//				}
//			}


//		printf("Kernel = %d\n", tid);
//		printf("dev_Lit = %d, dev_N = %d, dev_blockers = %d,  dev_flags = %d, dev_clauses = %d, dev_cindex = %d, assigns = %d\n", *dev_Lit, *dev_N, dev_blockers[tid], dev_flags[tid], dev_clauses[tid], dev_cindex[tid], dev_assigns[tid]);

//		printf("Clauses = ");
//		for(int a = 0; dev_clauses[dev_cindex[tid]+a] != -2 ; a++)
//			printf("%d, ", dev_clauses[dev_cindex[tid]+a]);
//		printf("\n");

//				printf("flag = %d", dev_flags[tid]);

//			int cnt = 0;
//			while(dev_clauses[dev_cindex[tid]+cnt] != -2){
//				cnt++;
//			}

//			printf("cnt = %d\n", cnt);
//					printf("After: c[1] = %d, c[k] = %d\n", dev_clauses[dev_cindex[tid]+1], dev_clauses[dev_cindex[tid]+k]);

//				printf("Here!");

//			if( value_4 == false_lit){
//				printf("assertion true proceed!");
//			}
//			printf("tid = %d, Kernel_blocker = %d, value_1 = %d\n", tid, dev_blockers[tid], value_1);


// 			atomicAdd(&(dev_assigns[var_f(first)]), sign_f(first));