`timescale 1ns / 1ps 
//and gate만들기 
module and_gate(
    input A,B,
    output F);
    
    and(F,A,B); //출력,입력여러개 
    
endmodule

module half_adder_structural( //구조적 모델링 : 구조를 알고 할 때 
    input A,B,
    output sum,carry
    );
    
    xor(sum,A,B); //half_adder 안에 쓰이는 논리구조 
    and(carry,A,B);
      
endmodule






//half_adder_동작적 모델링 
module half_adder_behavioral( // 동작적 모델링 :구조 몰라 동작만 이렇게 해주세요하고 선언 
    input A,B, //디폴트는 wire변수
    output reg sum,carry 
    );
    
    always @(A,B)begin //always의 왼쪽에 오는 건 reg선언필요 reg=메모리 메모리를 선언해주고 메모리 사용 
        case({A,B})
            2'b00:begin sum=0; carry=0; end //2bit짜리//바이너리(2진수)//비트두개//sum,carry모두 결정해서 보내준거  0+0
            2'b01:begin sum=1; carry=0; end //always문의 =왼쪽에 있는 변수는 reg변수 0+1 
            2'b10:begin sum=1; carry=0; end
            2'b11:begin sum=0; carry=1; end
            endcase
      end
      
endmodule


//half_adder_dataflow
module half_adder_detaflow(
    input A,B,
    output sum, carry
    );
    
    wire[1:0] sum_value; //선 두개짜리 변수 (2bit/즉,2칸의 공간)을 sum_value에 할당하겠다 
    
    assign sum_value = A+B; //assign문:변수에 어떤 변수를 넣어라 assign =왼쪽에 있는 것은 와이어(사용 선) 선언해줘야함 1비트짜리씩 두개니까 2개 
                            //A+B를 연산한 sum_value에는 0,1,2 3가지 연산이 나온다(2bit이므로 십진법으로 바꾸면 3 ->3가지)
    assign sum = sum_value[0]; //sum_value의 0번비트(최하위비트)를 sum에 저장하겠다 //sum_value에 있는  2가지 공간 중 첫번 째 공간에 sum을 넣겠다. 
    assign carry= sum_value[1]; //sum_value의 1번비트 자리를 carry에 저장한다 ////sum_value에 있는  2가지 공간 중 두번 째 공간에 sum을 넣겠다
    

endmodule


//full_adder_structural
module full_adder_structural(
    input A,B,cin,
    output sum,carry);
    
    wire sum_0,carry_0,carry_1;
    
    //회로 이어줘야하는 부분은  ha의 안쪽에 있는 게 아니고 바깥 부분에 있는 선들을 연결해줘야 함 
    half_adder_behavioral ha0 (.A(A),.B(B),.sum(sum_0),.carry(carry_0)); // 이미 있는는 half .A하면 불러온 애(ha)의 A 뒤에 A는 fa의 A를 연결한다는 의미 
     half_adder_behavioral ha1 (.A(sum_0),.B(cin),.sum(sum),.carry(carry_1)); // 불러온 애와 연결할 애 
     //sum(sum)은 ha1의 sum을 전체 sum이랑 연결해준다 
     
     or(carry,carry_0, carry_1); //출력, 입력, 입력 
     
 endmodule
 
 //1bit full_adder_동작적모델링
 module full_adder_behavioral(
    input A,B,cin,
    output reg sum,carry);
    
 always @(A,B,cin)begin //always의 왼쪽에 오는 건 reg선언필요 reg=메모리 메모리를 선언해주고 메모리 사용 
        case({A,B,cin})
            3'b000:begin sum=0; carry=0; end //3bit짜리//바이너리(2진수)//비트두개//sum,carry모두 결정해서 보내준거 
            3'b001:begin sum=1; carry=0; end //always문의 =왼쪽에 있는 변수는 reg변수 
            3'b010:begin sum=1; carry=0; end //3bit ->3자리 더했을 때 sum은1, 캐리는 0 
            3'b011:begin sum=0; carry=1; end
            3'b100:begin sum=1; carry=0; end
            3'b101:begin sum=0; carry=1; end
            3'b110:begin sum=0; carry=1; end
            3'b111:begin sum=1; carry=1; end
            endcase
            
      end
 endmodule
 
 //1bit full_adder_dataflow
 module full_adder_detaflow(
    input A,B,cin,
    output sum, carry
    );
    
    wire[1:0] sum_value; //선 두개짜리 변수 (2bit/즉,2칸의 공간)을 sum_value에 할당하겠다 
    //결과값으로 3까지 나옴 
    
    assign sum_value = A+B+cin; //assign문:변수에 어떤 변수를 넣어라 assign =왼쪽에 있는 것은 와이어(사용 선) 선언해줘야함 1비트짜리씩 두개니까 2개 
                            //A+B를 연산한 sum_value에는 0,1,2 3가지 연산이 나온다(2bit이므로 십진법으로 바꾸면 3 ->3가지)
    assign sum = sum_value[0]; //sum_value의 0번비트(최하위비트)를 sum에 저장하겠다 //sum_value에 있는  2가지 공간 중 첫번 째 공간에 sum을 넣겠다. 
    assign carry= sum_value[1]; //sum_value의 1번비트 자리를 carry에 저장한다 ////sum_value에 있는  2가지 공간 중 두번 째 공간에 sum을 넣겠다
    

endmodule


//4bit_full_adder _구조적 모델링 
  module fadder_4bit_s(
    input [3:0]A,B,
    input cin,
    output [3:0]sum,
    output carry);
    
    wire [2:0] carry_w; //필요한 선 3개 3비트 -> 0~2 선언 :방 3개 만듦  carry_w라는 이름 안에  방 3개  
 

  //리플캐리에더 캐리 값이 delay시간이 누적되서 느려짐 carry[0
    full_adder_structural fa0 (.A(A[0]),.B(B[0]),.cin(cin), .sum(sum[0]),.carry(carry_w[0])); 
    full_adder_structural fa1( .A(A[1]), .B(B[1]), .cin(carry_w[0]), .sum(sum[1]),.carry(carry_w[1]));
    full_adder_structural fa2( .A(A[2]), .B(B[2]), .cin(carry_w[1]), .sum(sum[2]),.carry(carry_w[2]));
    full_adder_structural fa3( .A(A[3]), .B(B[3]), .cin(carry_w[2]), .sum(sum[3]),.carry(carry));
  
    
  endmodule

  
  //4bit_full_adder_데이터플로우 모델링 
   module fadder_4bit(
    input [3:0]A,B, //A,B를 4bit로 만들겠다. (4bit+4bit니까)
    input cin,
    output [3:0]sum,
    output carry);
    
    wire[4:0] temp;//temp안에 4bit + 4bit 라 5bit필요하니까 5칸 만들어줌 
    
    assign temp = A+B+cin; 
    assign sum = temp[3:0]; // 비트 수만 조정해주면 1bit fulladder랑 비슷 -> 많이 사용 //4칸을 각각sum배열대로 받겠다 
    assign carry= temp[4]; //제일 최상위비트는 carry로 사용 
    //temp[4:0] -> 최상위carry,sum[3:0] -> 총 5자리로 나타남 
    //A:0101, B:0001, cin:0, sum[3:0]:0110 (A+B값) carry:0,temp[4:0] :00110 이 나옴  
    
 
    endmodule
  
  
  //병렬 가감산기 구조적 모델링 
  module fadd_sub_4bit_s( 
    input [3:0]A,B,
    input s,   //add : s=0;, sub(빼기): s=1
    output [3:0]sum,
    output carry);
    
    wire [2:0] carry_w; //필요한 선 3개 3비트 -> 0~2 선언 :방 3개 만듦  carry_w라는 이름 안에  방 3개  
  
    wire s0;
    xor (s0,B[0],s); //^:xor , &:and , |:or, ~ :not , ~^:xnor ->비트논리연산자 
  
    full_adder_structural fa0 (.A(A[0]), .B(B[0]^s), .cin(s), .sum(sum[0]),.carry(carry_w[0])); //full adder의 b를 s와 xor을 해서 값을 줘야함 
    full_adder_structural fa1( .A(A[1]), .B(B[1]^s), .cin(carry_w[0]), .sum(sum[1]),.carry(carry_w[1])); //.B(B[1]^s == B(s1)
    full_adder_structural fa2( .A(A[2]), .B(B[2]^s), .cin(carry_w[1]), .sum(sum[2]),.carry(carry_w[2]));
    full_adder_structural fa3( .A(A[3]), .B(B[3]^s), .cin(carry_w[2]), .sum(sum[3]),.carry(carry)); 
    //not(carry,carry_w[3]);
   
  //구조적 모델링할 때 음수이면 -> carry 0 양수이면->carry 1    -->데이터 플로우모델링에서는 반전됨 그래도 원래대로 나오게 바꿨음 
  //but'' 캐리를 최상위비트로 사용할거면 캐리 반전시켜야 함 
  //밑에 데이터 모델링할때도 그렇게 뜨는 것임 
    
  endmodule
  
  //병렬 가감산기 데이터 플로우 모델링 
  module fadd_sub_4bit(
    input [3:0]A,B,
    input s,
    output [3:0] sum,
    output carry);
    
    wire[4:0] temp;
    assign temp = s ?  A - B : A + B;
    assign sum = temp[3:0];
    assign carry = ~temp[4]; //structural이랑 값 같게 하려고 반전 
  
  endmodule

  //비교기 assign문을 썼지만 구조적모델링과 같음 A~^B 이런 부분 대문에 (하나하나 구조 정해준 것) 
  module comparator_sub(
    input A,B,
    output equal,greater,less);
    
    assign equal = A ~^ B; //~^:xnor 
    assign greater =  A & ~B;
    assign less = ~A & B;
    
    
endmodule
 //비교기 데이터플로우 모델링
 module comparator_dataflow(
    input A,B,
    output equal,greater,less);
    
    assign equal = (A == B)? 1'b1 : 1'b0; 
    assign greater =  (A > B) ? 1'b1 : 1'b0;
    assign less = (A < B) ? 1'b1 : 1'b0;
    
    
endmodule


//여러 비트짜리 비교기 파라미터 (데이터플로우 모델링 사용) 
 module comparator_N_bit #(parameter N = 4)(
    input [N-1:0 ]A,B, //4비트 짜리니까 [3:0]이 되어야 함 
    output equal,greater,less);
    
    assign equal = (A == B)? 1'b1 : 1'b0;  //조건연산자 test식 ? A : B ==> test식 참이면 A, 거짓이면 B 1'b1 
    assign greater =  (A > B) ? 1'b1 : 1'b0;//d-십진수, b-2진수 
    assign less = (A < B) ? 1'b1 : 1'b0;
    
    
endmodule


//N-bit 비교기 파라미터 생성하는법  ------>구조적 모델링(???????????) 
module comparator_N_bit_test(
    input[1:0]A,B,
    output equal,greater,less);
    
    comparator_N_bit #(.N(2)) //16안쓰면 디폴트 값인 8비트 들어감 
     c_16(.A(A), // c_16이 만들어짐 
     .B(B), 
    .equal(equal), .greater(greater), .less(less));
    
endmodule

//비교기 동작적 모델링 
  module comparator_N_bit_b #(parameter N = 4)(
    input [N-1:0 ]  A , B , //4비트 짜리니까 [3:0]이 되어야 함 
    output reg equal,greater,less); //reg선언 반드시 해야함 
    
    always @(A,B) begin  //always문 안에 = 왼쪽에 있는 것들은 reg선언해줘야함 
//         equal = (A == B)? 1'b1 : 1'b0; 
//         //assign alwyas문에는 조건연산자 대신에 if문 쓰기 가능 (제어문: 문법연산자) 사용 가능 
//         assign문은 if문 못 쓰고 조건 연산자 밖에 못씀 
//         assign : 조건연산자 사용
//         always : 조건문 사용 
        if(A == B) begin  // 조건문 :if문 () : 괄호 안의 값이 참이면 if문 블럭 안의 값을 실행 
            equal = 1;    
            greater = 0;
            less = 0;
        end
          else if(A > B) begin  // if문만 쓰면 끝까지 비교 다 하는데(A=B여도 끝까지 동작)  else if 쓰면 해당 될 때까지만 (이 전의 값을 받아서) 
            equal = 0; 
            greater = 1;
            less = 0;
        end
        
        else begin //이 결과값이 나올리 없더라도 if했ㅇ면 else가 나와야함 
            equal = 0; 
            greater = 0;
            less = 1;
        end
    end
   endmodule
   
   
   //디코더 
 module decoder_2_4_s(
   input [1:0]  code,
   output [3:0] signal );
   
   wire [1:0] code_bar;
   not (code_bar[0], code[0]);
   not (code_bar[1], code[1]);
   
   and (signal[0], code_bar[1], code_bar[0]);
   and (signal[1], code_bar[1], code[0]);
   and (signal[2], code[1], code_bar[0]);
   and (signal[3], code[1], code[0]);    
   
   endmodule
  
  //디코더 동작적 모델링  
module decoder_2_4_b(
   input[1:0] code,
   output reg [3:0] signal);
   
//   always @(code)
//    if      (code == 2'b00) signal = 4'b0001;
//    else if (code == 2'b01) signal = 4'b0010;
//    else if (code == 2'b10) signal = 4'b0100;
//    else                    signal = 4'b1000;

   always @(code) begin
        case(code)
           2'b00: signal = 4'b0001;
            2'b01:signal = 4'b0010;
            2'b10:signal = 4'b0100;
            2'b11:signal = 4'b1000;
            endcase
      end
   
   //always문 안에 case문 하나 있음 -> begin,end생략가능 
  endmodule
 
 

   //////// /en이있는 2*4디코더_동작적 모델링으로  만들기 //////////////////////////////////////////////
 module decoder_2_4_b_en(
   input[1:0] code,
   input en,
   output reg [3:0] signal
   );
   
     always @(code) begin
      if(en==1) 
        case(code) 
            2'b00: signal= 4'b0001;
            2'b01:signal = 4'b0010;
            2'b10:signal = 4'b0100;
            2'b11:signal = 4'b1000;
         endcase
         
     else 
            signal= 4'b0000;
      
     end 
     
   endmodule
 
   
   
   //////// /en이있는 3*8디코더 _구조적 모델링으로 만들기 (en이 있는 2*4 디코더_동작적 모델링 2개 연결) //////////////////////////////////////////////////////////
 module decoder_3_8_b_en(
    input [2:0] code,
    output[7:0] signal); 
    
    decoder_2_4_b_en dec_low (.code(code[1:0]) , .en(~code[2]), .signal(signal[3:0]));    
    decoder_2_4_b_en dec_high (.code(code[1:0]) , .en(code[2]), .signal(signal[7:4])); 
    
    endmodule

 
   //디코더 데이터플로우 모델링 
 module decoder_2_4_d(
     input[1:0] code, //2칸짜리 input code방 선언
     output [3:0] signal);// 0~3 4칸짜리 output signal방 선언 
   
    assign signal = (code == 2'b00) ? 4'b0001 : // code = 00이 참이면 signal=0001출력 //거짓이면 다음 줄로 
                    (code == 2'b01) ? 4'b0010 : //code=00이 거짓이면 실행되는 구문 //code=01이 참이면 signal=0010 //거짓이면 다음 줄로 
                    (code == 2'b10) ? 4'b0100: 4'b1000;  //code=01이 거짓이면 실행되는 구문 //code=10이면 signal=0100 //code=10이 거짓이면 signal=1000출력  
   
   
 endmodule
 
 

 //enable이 있는 2*4 디코더 데이터플로우 모델링 
 module decoder_2_4_en(
     input[1:0] code,
     input enable,
     output [3:0] signal);

    assign signal = (enable == 1'b0 ) ? 4 'b0000 : //enable이 0이면 signal=0000// 아니면(enable=1) 다음 줄 실행
    (code == 2'b00)  ? 4'b0001 :  // code = 00이 참이면 signal=0001출력 //거짓이면 다음 줄로
    (code == 2'b01) ? 4'b0010 :   //code=00이 거짓이면 실행되는 구문 //code=01이 참이면 signal=0010 //거짓이면 다음 줄로
    (code == 2'b10) ? 4'b0100: 4'b1000;  //code=01이 거짓이면 실행되는 구문 //code=10이면 signal=0100 //code=10이 거짓이면 signal=1000출력 
   
  
 endmodule
 
 
 
  //3*8디코더 2*4 2개 이어붙이기 구조적 모델링  
 module decoder_3_8(
    input [2:0] code,
    output[7:0] signal);
    
    decoder_2_4_en dec_low (.code(code[1:0]), //decoder_2_4_en의 code를 현재 파일의 code[1:0]과 연결 //low (1입력->0출력) 
                           .enable(~code[2]),//decoder_2_4_en의 enable을 현재 파일의 ~code[2]와 연결 
                      .signal(signal[3:0]));//decoder_2_4_en의 signal를 현재 파일의 signal[3:0]과 연결    
    decoder_2_4_en dec_high (.code(code[1:0]) , 
                              .enable(code[2]), 
                         .signal(signal[7:4])); //decoder_2_4_en의 signal를 현재 파일의 signal[7:4]과 연결 //high (1입력->1출력)
    
    endmodule
 
  //인코더 데이터플로우 모델링 
 module encoder_4_2(
    input [3:0] signal,
    output[1:0] code);
    
    assign code = (signal == 4'b0001) ? 2'b00 :
     (signal == 4'b0010) ? 2'b01 : (signal == 4'b0100 ) ? 2'b10 : 2'b11; //0001,0010,0100 을 제외한 값이 나오면 11이 나옴 -> 다른 부분 안 들어가게 해야함 
 
 endmodule
 
 //BCD 7segment 디코더 최하위 4비트 같은 숫자 들어오게 하기 애노드 ->0인 곳에 불이 들어옴
 //애노드 인데 그 사이에  tr있어서 1인데 안켜지고 0일 때 켜짐 
module decoder_7seg (
    input [3:0] hex_value, // 4비트 입력
    output reg [7:0] seg_7 // 8비트 출력, 7세그먼트 디스플레이 값
);
always @(hex_value) begin //hex_value = 불빛 
    // 7세그먼트 디스플레이 값 설정
    case(hex_value)
        
                                //dpgfe_dcba//1인 게 안켜지는 거 0인게 켜짐 
            4'b0000: seg_7 = 8'b1100_0000; //0   ////// 8'b11; 해도됨
            4'b0001: seg_7 = 8'b1111_1001; //1   ///// 언더바 써줘도 숫자만 읽음.
            4'b0010: seg_7 = 8'b1010_0100; //2
            4'b0011: seg_7 = 8'b1011_0000; //3
            4'b0100: seg_7 = 8'b1001_1001; //4
            4'b0101: seg_7 = 8'b1001_0010; //5
            4'b0110: seg_7 = 8'b1000_0010; //6
            4'b0111: seg_7 = 8'b1101_1000; //7
            4'b1000: seg_7 = 8'b1000_0000; //8
            4'b1001: seg_7 = 8'b1001_0000; //9
            4'b1010: seg_7 = 8'b1000_1000; //A
            4'b1011: seg_7 = 8'b1000_0011; //B
            4'b1100: seg_7 = 8'b1100_0110; //C
            4'b1101: seg_7 = 8'b1010_0001; //D
            4'b1110: seg_7 = 8'b1000_0110; //E
            4'b1111: seg_7 = 8'b1000_1110; //f
 
    endcase
    // 활성화할 디스플레이 선택
end
endmodule


//BCD 7세그먼트 최하위 4비트로 숫자입력 받고 상위 4비트로 숫자 출력할 자리 선정하기
module decoder_7seg_extra (
    input [3:0] hex_value, // 4비트 입력
    input [3:0] an_value, // 4비트 입력
    output reg [7:0] seg_7, // 8비트 출력
    output reg [3:0] an // 8비트 출력
);
always @(hex_value,an_value) begin
    case(hex_value)       //abcd_efgp
        4'b0000: seg_7 = 8'b0000_0011;  //0
        4'b0001: seg_7 = 8'b1001_1111;  //1
        4'b0010: seg_7 = 8'b0010_0101;  //2
        4'b0011: seg_7 = 8'b0000_1101;  //3
        4'b0100: seg_7 = 8'b1001_1001;  //4
        4'b0101: seg_7 = 8'b0100_1001;  //5
        4'b0110: seg_7 = 8'b0100_0001;  //6
        4'b0111: seg_7 = 8'b0001_1001;  //7
        4'b1000: seg_7 = 8'b0000_0001;  //8
        4'b1001: seg_7 = 8'b0001_1001;  //9
        4'b1010: seg_7 = 8'b0001_0001;  //A
        4'b1011: seg_7 = 8'b1100_0001;  //b
        4'b1100: seg_7 = 8'b0110_0011;  //C
        4'b1101: seg_7 = 8'b1000_0101;  //d
        4'b1110: seg_7 = 8'b0110_0001;  //E
        4'b1111: seg_7 = 8'b0111_0001;  //F
    endcase
    case(an_value)
        4'b0000: an = 4'b1111;
        4'b0001: an = 4'b1110;
        4'b0010: an = 4'b1101;
        4'b0011: an = 4'b1100;
        4'b0100: an = 4'b1011;
        4'b0101: an = 4'b1010;
        4'b0110: an = 4'b1001;
        4'b0111: an = 4'b1000;
        4'b1000: an = 4'b0111;
        4'b1001: an = 4'b0110;
        4'b1010: an = 4'b0101;
        4'b1011: an = 4'b0100;
        4'b1100: an = 4'b0011;
        4'b1101: an = 4'b0010;
        4'b1110: an = 4'b0001;
        4'b1111: an = 4'b0000;
    endcase
end
endmodule

//2*1 멀티플렉서
  module mux_2_1(
    input [1:0] d,
    input s,
    output f);
   wire sbar, w0, w1;
        not(sbar,s);
        and(w0, sbar, d[0]);
        and(w1, s,d[1]);
        or(f, w0,w1);
endmodule

//2*1 멀티플렉서 
 module mux_2_1_dataflow(
    input [1:0] d,
    input s,
    output f);
   assign f = s ? d[1] : d[0]; //not이 D0에 달려있어서 S와 출력값이 같으면 D1, 출력값이 다르면 D0
    //s가 0이면 d[0] s가 1이면 d[1]을 출력
 endmodule
 


//MUX 4*1 
module mux_4_1(
    input [3:0] d,
    input [1:0] s,
    output f);
   assign f =d[s]; //s가 01일 때는 d[1] s가 11일 때는 D[3] 
endmodule


//MUX 8*1
module mux_8_1(
    input [7:0] d,
    input [2:0] s,  //5 배 주기가 0번 그거의 2배가 1번  //s로 입력으로 나올 수 있는 종류를 다 나타내야함 
    //입력이 8개니까 s가 입력의 종류를 다 포혐하려면 3bit가 필요 
    output f);
   assign f =d[s]; //s가 1일 때는 d[1] s가 0011일 때는 D[3]
endmodule



//DEMUX_1*4 
module demux_1_4(
    input d,
    input [1:0] s, //출력이 4개니까 select를 2개필요
    output [3:0] f);   //d가 1번비트가되고 0번비트는 0 
    
    assign f= (s == 2'b00) ? {3'b000 , d} : //s가 00일 때 출력으로 000d가 나옴 
              (s == 2'b01) ? {2'b00, d, 1'b0 }://s가 01(1)일 때 출력으로 00d0(1번비트에 출력)이 나옴 -->f[1]에 파형이 나옴  
              (s == 2'b10) ? {1'b0, d, 2'b00} : // s가 10(2)일 때, 출력으로 0b00(2번비트에 출력)이 나옴 -->f[2]에 파형이 나옴   
                                {d, 3'b000}; // s가 11(3)일 때, 출력으로 d000이 나옴 
                    
                    
  endmodule
 
 //mux_demux연결 구조적 모델링 
 module mux_demux(
    input [7:0] d,
    input [2:0] s_mux, //mux의 s
    input [1:0] s_demux, //demux의 s
    output [3:0] f); //demux의 출력이 4개 
    
    
    wire w;
 
    
 mux_8_1 mux( //모듈명, 인스턴스명(mux)
    .d(d), .s(s_mux), .f(w)  );
 
 
demux_1_4 demux(
   .d(w), .s(s_demux), .f(f) ); 
 
 endmodule
 
 
 ///////////////////조합회로 끝//////////////////////////////////////////
 
 module bin_to_dec( //10진화 2진수 25로 들어오면 37로 나가게 하는 코드
        input [11:0] bin,
        output reg [15:0] bcd
    );
    reg [3:0] i;
    always @(bin) begin
        bcd = 0;
        for (i=0;i<12;i=i+1)begin
            bcd = {bcd[14:0], bin[11-i]}; //좌시프트 
            if(i < 11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if(i < 11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if(i < 11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if(i < 11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
        end
    end
endmodule
 