`timescale 1ns / 1ps 
//and gate����� 
module and_gate(
    input A,B,
    output F);
    
    and(F,A,B); //���,�Է¿����� 
    
endmodule

module half_adder_structural( //������ �𵨸� : ������ �˰� �� �� 
    input A,B,
    output sum,carry
    );
    
    xor(sum,A,B); //half_adder �ȿ� ���̴� ������ 
    and(carry,A,B);
      
endmodule






//half_adder_������ �𵨸� 
module half_adder_behavioral( // ������ �𵨸� :���� ���� ���۸� �̷��� ���ּ����ϰ� ���� 
    input A,B, //����Ʈ�� wire����
    output reg sum,carry 
    );
    
    always @(A,B)begin //always�� ���ʿ� ���� �� reg�����ʿ� reg=�޸� �޸𸮸� �������ְ� �޸� ��� 
        case({A,B})
            2'b00:begin sum=0; carry=0; end //2bit¥��//���̳ʸ�(2����)//��Ʈ�ΰ�//sum,carry��� �����ؼ� �����ذ�  0+0
            2'b01:begin sum=1; carry=0; end //always���� =���ʿ� �ִ� ������ reg���� 0+1 
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
    
    wire[1:0] sum_value; //�� �ΰ�¥�� ���� (2bit/��,2ĭ�� ����)�� sum_value�� �Ҵ��ϰڴ� 
    
    assign sum_value = A+B; //assign��:������ � ������ �־�� assign =���ʿ� �ִ� ���� ���̾�(��� ��) ����������� 1��Ʈ¥���� �ΰ��ϱ� 2�� 
                            //A+B�� ������ sum_value���� 0,1,2 3���� ������ ���´�(2bit�̹Ƿ� ���������� �ٲٸ� 3 ->3����)
    assign sum = sum_value[0]; //sum_value�� 0����Ʈ(��������Ʈ)�� sum�� �����ϰڴ� //sum_value�� �ִ�  2���� ���� �� ù�� ° ������ sum�� �ְڴ�. 
    assign carry= sum_value[1]; //sum_value�� 1����Ʈ �ڸ��� carry�� �����Ѵ� ////sum_value�� �ִ�  2���� ���� �� �ι� ° ������ sum�� �ְڴ�
    

endmodule


//full_adder_structural
module full_adder_structural(
    input A,B,cin,
    output sum,carry);
    
    wire sum_0,carry_0,carry_1;
    
    //ȸ�� �̾�����ϴ� �κ���  ha�� ���ʿ� �ִ� �� �ƴϰ� �ٱ� �κп� �ִ� ������ ��������� �� 
    half_adder_behavioral ha0 (.A(A),.B(B),.sum(sum_0),.carry(carry_0)); // �̹� �ִ´� half .A�ϸ� �ҷ��� ��(ha)�� A �ڿ� A�� fa�� A�� �����Ѵٴ� �ǹ� 
     half_adder_behavioral ha1 (.A(sum_0),.B(cin),.sum(sum),.carry(carry_1)); // �ҷ��� �ֿ� ������ �� 
     //sum(sum)�� ha1�� sum�� ��ü sum�̶� �������ش� 
     
     or(carry,carry_0, carry_1); //���, �Է�, �Է� 
     
 endmodule
 
 //1bit full_adder_�������𵨸�
 module full_adder_behavioral(
    input A,B,cin,
    output reg sum,carry);
    
 always @(A,B,cin)begin //always�� ���ʿ� ���� �� reg�����ʿ� reg=�޸� �޸𸮸� �������ְ� �޸� ��� 
        case({A,B,cin})
            3'b000:begin sum=0; carry=0; end //3bit¥��//���̳ʸ�(2����)//��Ʈ�ΰ�//sum,carry��� �����ؼ� �����ذ� 
            3'b001:begin sum=1; carry=0; end //always���� =���ʿ� �ִ� ������ reg���� 
            3'b010:begin sum=1; carry=0; end //3bit ->3�ڸ� ������ �� sum��1, ĳ���� 0 
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
    
    wire[1:0] sum_value; //�� �ΰ�¥�� ���� (2bit/��,2ĭ�� ����)�� sum_value�� �Ҵ��ϰڴ� 
    //��������� 3���� ���� 
    
    assign sum_value = A+B+cin; //assign��:������ � ������ �־�� assign =���ʿ� �ִ� ���� ���̾�(��� ��) ����������� 1��Ʈ¥���� �ΰ��ϱ� 2�� 
                            //A+B�� ������ sum_value���� 0,1,2 3���� ������ ���´�(2bit�̹Ƿ� ���������� �ٲٸ� 3 ->3����)
    assign sum = sum_value[0]; //sum_value�� 0����Ʈ(��������Ʈ)�� sum�� �����ϰڴ� //sum_value�� �ִ�  2���� ���� �� ù�� ° ������ sum�� �ְڴ�. 
    assign carry= sum_value[1]; //sum_value�� 1����Ʈ �ڸ��� carry�� �����Ѵ� ////sum_value�� �ִ�  2���� ���� �� �ι� ° ������ sum�� �ְڴ�
    

endmodule


//4bit_full_adder _������ �𵨸� 
  module fadder_4bit_s(
    input [3:0]A,B,
    input cin,
    output [3:0]sum,
    output carry);
    
    wire [2:0] carry_w; //�ʿ��� �� 3�� 3��Ʈ -> 0~2 ���� :�� 3�� ����  carry_w��� �̸� �ȿ�  �� 3��  
 

  //����ĳ������ ĳ�� ���� delay�ð��� �����Ǽ� ������ carry[0
    full_adder_structural fa0 (.A(A[0]),.B(B[0]),.cin(cin), .sum(sum[0]),.carry(carry_w[0])); 
    full_adder_structural fa1( .A(A[1]), .B(B[1]), .cin(carry_w[0]), .sum(sum[1]),.carry(carry_w[1]));
    full_adder_structural fa2( .A(A[2]), .B(B[2]), .cin(carry_w[1]), .sum(sum[2]),.carry(carry_w[2]));
    full_adder_structural fa3( .A(A[3]), .B(B[3]), .cin(carry_w[2]), .sum(sum[3]),.carry(carry));
  
    
  endmodule

  
  //4bit_full_adder_�������÷ο� �𵨸� 
   module fadder_4bit(
    input [3:0]A,B, //A,B�� 4bit�� ����ڴ�. (4bit+4bit�ϱ�)
    input cin,
    output [3:0]sum,
    output carry);
    
    wire[4:0] temp;//temp�ȿ� 4bit + 4bit �� 5bit�ʿ��ϴϱ� 5ĭ ������� 
    
    assign temp = A+B+cin; 
    assign sum = temp[3:0]; // ��Ʈ ���� �������ָ� 1bit fulladder�� ��� -> ���� ��� //4ĭ�� ����sum�迭��� �ްڴ� 
    assign carry= temp[4]; //���� �ֻ�����Ʈ�� carry�� ��� 
    //temp[4:0] -> �ֻ���carry,sum[3:0] -> �� 5�ڸ��� ��Ÿ�� 
    //A:0101, B:0001, cin:0, sum[3:0]:0110 (A+B��) carry:0,temp[4:0] :00110 �� ����  
    
 
    endmodule
  
  
  //���� ������� ������ �𵨸� 
  module fadd_sub_4bit_s( 
    input [3:0]A,B,
    input s,   //add : s=0;, sub(����): s=1
    output [3:0]sum,
    output carry);
    
    wire [2:0] carry_w; //�ʿ��� �� 3�� 3��Ʈ -> 0~2 ���� :�� 3�� ����  carry_w��� �̸� �ȿ�  �� 3��  
  
    wire s0;
    xor (s0,B[0],s); //^:xor , &:and , |:or, ~ :not , ~^:xnor ->��Ʈ�������� 
  
    full_adder_structural fa0 (.A(A[0]), .B(B[0]^s), .cin(s), .sum(sum[0]),.carry(carry_w[0])); //full adder�� b�� s�� xor�� �ؼ� ���� ����� 
    full_adder_structural fa1( .A(A[1]), .B(B[1]^s), .cin(carry_w[0]), .sum(sum[1]),.carry(carry_w[1])); //.B(B[1]^s == B(s1)
    full_adder_structural fa2( .A(A[2]), .B(B[2]^s), .cin(carry_w[1]), .sum(sum[2]),.carry(carry_w[2]));
    full_adder_structural fa3( .A(A[3]), .B(B[3]^s), .cin(carry_w[2]), .sum(sum[3]),.carry(carry)); 
    //not(carry,carry_w[3]);
   
  //������ �𵨸��� �� �����̸� -> carry 0 ����̸�->carry 1    -->������ �÷ο�𵨸������� ������ �׷��� ������� ������ �ٲ��� 
  //but'' ĳ���� �ֻ�����Ʈ�� ����ҰŸ� ĳ�� �������Ѿ� �� 
  //�ؿ� ������ �𵨸��Ҷ��� �׷��� �ߴ� ���� 
    
  endmodule
  
  //���� ������� ������ �÷ο� �𵨸� 
  module fadd_sub_4bit(
    input [3:0]A,B,
    input s,
    output [3:0] sum,
    output carry);
    
    wire[4:0] temp;
    assign temp = s ?  A - B : A + B;
    assign sum = temp[3:0];
    assign carry = ~temp[4]; //structural�̶� �� ���� �Ϸ��� ���� 
  
  endmodule

  //�񱳱� assign���� ������ �������𵨸��� ���� A~^B �̷� �κ� �빮�� (�ϳ��ϳ� ���� ������ ��) 
  module comparator_sub(
    input A,B,
    output equal,greater,less);
    
    assign equal = A ~^ B; //~^:xnor 
    assign greater =  A & ~B;
    assign less = ~A & B;
    
    
endmodule
 //�񱳱� �������÷ο� �𵨸�
 module comparator_dataflow(
    input A,B,
    output equal,greater,less);
    
    assign equal = (A == B)? 1'b1 : 1'b0; 
    assign greater =  (A > B) ? 1'b1 : 1'b0;
    assign less = (A < B) ? 1'b1 : 1'b0;
    
    
endmodule


//���� ��Ʈ¥�� �񱳱� �Ķ���� (�������÷ο� �𵨸� ���) 
 module comparator_N_bit #(parameter N = 4)(
    input [N-1:0 ]A,B, //4��Ʈ ¥���ϱ� [3:0]�� �Ǿ�� �� 
    output equal,greater,less);
    
    assign equal = (A == B)? 1'b1 : 1'b0;  //���ǿ����� test�� ? A : B ==> test�� ���̸� A, �����̸� B 1'b1 
    assign greater =  (A > B) ? 1'b1 : 1'b0;//d-������, b-2���� 
    assign less = (A < B) ? 1'b1 : 1'b0;
    
    
endmodule


//N-bit �񱳱� �Ķ���� �����ϴ¹�  ------>������ �𵨸�(???????????) 
module comparator_N_bit_test(
    input[1:0]A,B,
    output equal,greater,less);
    
    comparator_N_bit #(.N(2)) //16�Ⱦ��� ����Ʈ ���� 8��Ʈ �� 
     c_16(.A(A), // c_16�� ������� 
     .B(B), 
    .equal(equal), .greater(greater), .less(less));
    
endmodule

//�񱳱� ������ �𵨸� 
  module comparator_N_bit_b #(parameter N = 4)(
    input [N-1:0 ]  A , B , //4��Ʈ ¥���ϱ� [3:0]�� �Ǿ�� �� 
    output reg equal,greater,less); //reg���� �ݵ�� �ؾ��� 
    
    always @(A,B) begin  //always�� �ȿ� = ���ʿ� �ִ� �͵��� reg����������� 
//         equal = (A == B)? 1'b1 : 1'b0; 
//         //assign alwyas������ ���ǿ����� ��ſ� if�� ���� ���� (���: ����������) ��� ���� 
//         assign���� if�� �� ���� ���� ������ �ۿ� ���� 
//         assign : ���ǿ����� ���
//         always : ���ǹ� ��� 
        if(A == B) begin  // ���ǹ� :if�� () : ��ȣ ���� ���� ���̸� if�� �� ���� ���� ���� 
            equal = 1;    
            greater = 0;
            less = 0;
        end
          else if(A > B) begin  // if���� ���� ������ �� �� �ϴµ�(A=B���� ������ ����)  else if ���� �ش� �� �������� (�� ���� ���� �޾Ƽ�) 
            equal = 0; 
            greater = 1;
            less = 0;
        end
        
        else begin //�� ������� ���ø� ������ if�ߤ��� else�� ���;��� 
            equal = 0; 
            greater = 0;
            less = 1;
        end
    end
   endmodule
   
   
   //���ڴ� 
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
  
  //���ڴ� ������ �𵨸�  
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
   
   //always�� �ȿ� case�� �ϳ� ���� -> begin,end�������� 
  endmodule
 
 

   //////// /en���ִ� 2*4���ڴ�_������ �𵨸�����  ����� //////////////////////////////////////////////
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
 
   
   
   //////// /en���ִ� 3*8���ڴ� _������ �𵨸����� ����� (en�� �ִ� 2*4 ���ڴ�_������ �𵨸� 2�� ����) //////////////////////////////////////////////////////////
 module decoder_3_8_b_en(
    input [2:0] code,
    output[7:0] signal); 
    
    decoder_2_4_b_en dec_low (.code(code[1:0]) , .en(~code[2]), .signal(signal[3:0]));    
    decoder_2_4_b_en dec_high (.code(code[1:0]) , .en(code[2]), .signal(signal[7:4])); 
    
    endmodule

 
   //���ڴ� �������÷ο� �𵨸� 
 module decoder_2_4_d(
     input[1:0] code, //2ĭ¥�� input code�� ����
     output [3:0] signal);// 0~3 4ĭ¥�� output signal�� ���� 
   
    assign signal = (code == 2'b00) ? 4'b0001 : // code = 00�� ���̸� signal=0001��� //�����̸� ���� �ٷ� 
                    (code == 2'b01) ? 4'b0010 : //code=00�� �����̸� ����Ǵ� ���� //code=01�� ���̸� signal=0010 //�����̸� ���� �ٷ� 
                    (code == 2'b10) ? 4'b0100: 4'b1000;  //code=01�� �����̸� ����Ǵ� ���� //code=10�̸� signal=0100 //code=10�� �����̸� signal=1000���  
   
   
 endmodule
 
 

 //enable�� �ִ� 2*4 ���ڴ� �������÷ο� �𵨸� 
 module decoder_2_4_en(
     input[1:0] code,
     input enable,
     output [3:0] signal);

    assign signal = (enable == 1'b0 ) ? 4 'b0000 : //enable�� 0�̸� signal=0000// �ƴϸ�(enable=1) ���� �� ����
    (code == 2'b00)  ? 4'b0001 :  // code = 00�� ���̸� signal=0001��� //�����̸� ���� �ٷ�
    (code == 2'b01) ? 4'b0010 :   //code=00�� �����̸� ����Ǵ� ���� //code=01�� ���̸� signal=0010 //�����̸� ���� �ٷ�
    (code == 2'b10) ? 4'b0100: 4'b1000;  //code=01�� �����̸� ����Ǵ� ���� //code=10�̸� signal=0100 //code=10�� �����̸� signal=1000��� 
   
  
 endmodule
 
 
 
  //3*8���ڴ� 2*4 2�� �̾���̱� ������ �𵨸�  
 module decoder_3_8(
    input [2:0] code,
    output[7:0] signal);
    
    decoder_2_4_en dec_low (.code(code[1:0]), //decoder_2_4_en�� code�� ���� ������ code[1:0]�� ���� //low (1�Է�->0���) 
                           .enable(~code[2]),//decoder_2_4_en�� enable�� ���� ������ ~code[2]�� ���� 
                      .signal(signal[3:0]));//decoder_2_4_en�� signal�� ���� ������ signal[3:0]�� ����    
    decoder_2_4_en dec_high (.code(code[1:0]) , 
                              .enable(code[2]), 
                         .signal(signal[7:4])); //decoder_2_4_en�� signal�� ���� ������ signal[7:4]�� ���� //high (1�Է�->1���)
    
    endmodule
 
  //���ڴ� �������÷ο� �𵨸� 
 module encoder_4_2(
    input [3:0] signal,
    output[1:0] code);
    
    assign code = (signal == 4'b0001) ? 2'b00 :
     (signal == 4'b0010) ? 2'b01 : (signal == 4'b0100 ) ? 2'b10 : 2'b11; //0001,0010,0100 �� ������ ���� ������ 11�� ���� -> �ٸ� �κ� �� ���� �ؾ��� 
 
 endmodule
 
 //BCD 7segment ���ڴ� ������ 4��Ʈ ���� ���� ������ �ϱ� �ֳ�� ->0�� ���� ���� ����
 //�ֳ�� �ε� �� ���̿�  tr�־ 1�ε� �������� 0�� �� ���� 
module decoder_7seg (
    input [3:0] hex_value, // 4��Ʈ �Է�
    output reg [7:0] seg_7 // 8��Ʈ ���, 7���׸�Ʈ ���÷��� ��
);
always @(hex_value) begin //hex_value = �Һ� 
    // 7���׸�Ʈ ���÷��� �� ����
    case(hex_value)
        
                                //dpgfe_dcba//1�� �� �������� �� 0�ΰ� ���� 
            4'b0000: seg_7 = 8'b1100_0000; //0   ////// 8'b11; �ص���
            4'b0001: seg_7 = 8'b1111_1001; //1   ///// ����� ���൵ ���ڸ� ����.
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
    // Ȱ��ȭ�� ���÷��� ����
end
endmodule


//BCD 7���׸�Ʈ ������ 4��Ʈ�� �����Է� �ް� ���� 4��Ʈ�� ���� ����� �ڸ� �����ϱ�
module decoder_7seg_extra (
    input [3:0] hex_value, // 4��Ʈ �Է�
    input [3:0] an_value, // 4��Ʈ �Է�
    output reg [7:0] seg_7, // 8��Ʈ ���
    output reg [3:0] an // 8��Ʈ ���
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

//2*1 ��Ƽ�÷���
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

//2*1 ��Ƽ�÷��� 
 module mux_2_1_dataflow(
    input [1:0] d,
    input s,
    output f);
   assign f = s ? d[1] : d[0]; //not�� D0�� �޷��־ S�� ��°��� ������ D1, ��°��� �ٸ��� D0
    //s�� 0�̸� d[0] s�� 1�̸� d[1]�� ���
 endmodule
 


//MUX 4*1 
module mux_4_1(
    input [3:0] d,
    input [1:0] s,
    output f);
   assign f =d[s]; //s�� 01�� ���� d[1] s�� 11�� ���� D[3] 
endmodule


//MUX 8*1
module mux_8_1(
    input [7:0] d,
    input [2:0] s,  //5 �� �ֱⰡ 0�� �װ��� 2�谡 1��  //s�� �Է����� ���� �� �ִ� ������ �� ��Ÿ������ 
    //�Է��� 8���ϱ� s�� �Է��� ������ �� �����Ϸ��� 3bit�� �ʿ� 
    output f);
   assign f =d[s]; //s�� 1�� ���� d[1] s�� 0011�� ���� D[3]
endmodule



//DEMUX_1*4 
module demux_1_4(
    input d,
    input [1:0] s, //����� 4���ϱ� select�� 2���ʿ�
    output [3:0] f);   //d�� 1����Ʈ���ǰ� 0����Ʈ�� 0 
    
    assign f= (s == 2'b00) ? {3'b000 , d} : //s�� 00�� �� ������� 000d�� ���� 
              (s == 2'b01) ? {2'b00, d, 1'b0 }://s�� 01(1)�� �� ������� 00d0(1����Ʈ�� ���)�� ���� -->f[1]�� ������ ����  
              (s == 2'b10) ? {1'b0, d, 2'b00} : // s�� 10(2)�� ��, ������� 0b00(2����Ʈ�� ���)�� ���� -->f[2]�� ������ ����   
                                {d, 3'b000}; // s�� 11(3)�� ��, ������� d000�� ���� 
                    
                    
  endmodule
 
 //mux_demux���� ������ �𵨸� 
 module mux_demux(
    input [7:0] d,
    input [2:0] s_mux, //mux�� s
    input [1:0] s_demux, //demux�� s
    output [3:0] f); //demux�� ����� 4�� 
    
    
    wire w;
 
    
 mux_8_1 mux( //����, �ν��Ͻ���(mux)
    .d(d), .s(s_mux), .f(w)  );
 
 
demux_1_4 demux(
   .d(w), .s(s_demux), .f(f) ); 
 
 endmodule
 
 
 ///////////////////����ȸ�� ��//////////////////////////////////////////
 
 module bin_to_dec( //10��ȭ 2���� 25�� ������ 37�� ������ �ϴ� �ڵ�
        input [11:0] bin,
        output reg [15:0] bcd
    );
    reg [3:0] i;
    always @(bin) begin
        bcd = 0;
        for (i=0;i<12;i=i+1)begin
            bcd = {bcd[14:0], bin[11-i]}; //�½���Ʈ 
            if(i < 11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
            if(i < 11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
            if(i < 11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
            if(i < 11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3;
        end
    end
endmodule
 