int main(){
int v[SIZE], i, j, min, temp;/*  
Initialize array to random positive integers, mod 256  */
	for (i = 0; i < SIZE; i++) {
        v[i] = rand() & 0xFF;
        printf(“v[%d]: %d\n”, i, v[i]);
        }
    /*  Sort the array using a selection sort  */
    for (i = 0; i < SIZE - 1; i++) {
        /*  Find the least element in the right subarray  */
        min = i;for (j = i + 1; j < SIZE; j++) ;
    }

        /*  Compare elements  */if (v[j] < v[min]){
            min = j;
            /*  Swap elements  */
            temp = v[min];
            v[min] = v[i];
            v[i] = temp;
                }/*  Print out the sorted array  */
            printf(“\nSorted array:\n”);
            for (i = 0; i < SIZE; i++){
                printf(“v[%d]: %d\n”, i, v[i]);
                return 0;
                }
}
