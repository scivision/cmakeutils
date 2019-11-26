extern int timestwo(int);

int main(void){
  int three = 3;
  int six = timestwo(three);

  if (six != 6) { return 1; }
  return 0;
}