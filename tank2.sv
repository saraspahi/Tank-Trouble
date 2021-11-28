//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module tank2 ( input Reset, frame_clk,
               input [7:0] sin, cos,
					input [31:0] keycode,
               output [9:0]  BallX, BallY, BallS,
					output [5:0] Angle);//inxe
    
   logic [9:0] Ball_X_Pos, Ball_Y_Pos, Ball_Size;
	logic [9:0] Ball_X_Motion, Ball_Y_Motion;
	logic [5:0] Angle_Motion,Angle_new;
	
	logic [7:0] key;
    logic [15:0] Ball_X_Comp, Ball_Y_Comp;
	 logic signX, signY;
    always_comb
    begin
		  signX = Ball_X_Step[7] ^ cos[7];
		  signY = Ball_Y_Step[7] ^ sin[7];
        Ball_X_Comp[15:0] = Ball_X_Step[6:0]*cos[6:0];
        Ball_Y_Comp[15:0] = Ball_Y_Step[6:0]*sin[6:0];
    end    

    parameter [9:0] Ball_X_Center=300;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=250;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [7:0] Ball_X_Step=8'b0101_0000;      // Step size on the X axis
    parameter [7:0] Ball_Y_Step=8'b0101_0000;      // Step size on the Y axis
    parameter [5:0] AngleStep= 5'b00001;				//angle counter clockwise step 1 corresponds to 4 degrees. 22 is 360 set to 0

    assign Ball_Size = 10;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Angle_Motion <=   5'd0;	      //Ball angle step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
				Angle_new <= 0;
        end
           
        else 
        begin 
 
					 
					  Ball_Y_Motion <= 10'd0 ;  // Ball is somewhere in the middle, don't move
					  Ball_X_Motion <= 10'd0;
					  Angle_Motion <= 5'd0;

				 
				 if ((keycode[31:24] ==8'h52 )||(keycode[23:16]==8'h52)||(keycode[15:8] ==8'h52)||(keycode[7:0]==8'h52))
					  key <= 8'h52;
				 else if ((keycode[31:24] ==8'h51 )||(keycode[23:16]==8'h51)||(keycode[15:8] ==8'h51)||(keycode[7:0]==8'h51))
					  key <= 8'h51;
				 else if ((keycode[31:24] ==8'h50 )||(keycode[23:16]==8'h50)||(keycode[15:8] ==8'h50)||(keycode[7:0]==8'h50))
					  key <= 8'h50;
				 else if ((keycode[31:24] ==8'h4f )||(keycode[23:16]==8'h4f)||(keycode[15:8] ==8'h4f)||(keycode[7:0]==8'h4f))
					  key <= 8'h4f;
				 else 
					  key <= 8'h00;  
				 
				 case (key)
					8'h50 : begin
							
								begin
									Ball_X_Motion <= 0;//A
									Ball_Y_Motion<= 0;
									Angle_Motion <=  AngleStep;
								end
							  end
					        
					8'h4f : begin
							
								begin
									Ball_X_Motion <= 0;//D
									Ball_Y_Motion <= 0;
									Angle_Motion <=  ~(AngleStep) + 1;      // Descreases the angle
								end
							  end
							  
					8'h52 : begin
							  begin
									//Ball_Y_Motion[9] <= signY;
                           //Ball_X_Motion[9] <= signX;
									Ball_Y_Motion[9:0] <=  {{6{~signY}},~Ball_Y_Comp[10:7]} + 1'b1;//S
									Ball_X_Motion[9:0] <=  {{6{signX}},Ball_X_Comp[10:7]};
									Angle_Motion <=0;
								end
							 end
							  
					8'h51 : begin
								begin
                           //Ball_Y_Motion[9] <= ~signY;
                           //Ball_X_Motion[9] <= ~signX;
									Ball_Y_Motion[9:0] <= {{6{signY}}, Ball_Y_Comp[10:7]};//S
									Ball_X_Motion[9:0] <= {{6{~signX}}, ~Ball_X_Comp[10:7]} + 1'b1;
									Angle_Motion <=0;
								end
							end
								  
					default: ;
			   endcase
				 
				 Ball_Y_Pos[9:0] <= (Ball_Y_Pos[9:0] + Ball_Y_Motion[9:0]);  // Update ball position
				 Ball_X_Pos[9:0] <= (Ball_X_Pos[9:0] + Ball_X_Motion[9:0]);
		
				 
				 if(Angle_new >= 45 && Angle_new <=48)
					Angle_new <= 0;
				 else if(Angle_new >=51)
					Angle_new <= 44;
             else
				   Angle_new <= Angle_new + Angle_Motion;      //change it to 0 when 360
			
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
	 
	assign Angle = Angle_new;
    

endmodule
