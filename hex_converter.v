module hexConverter(
  input  [3:0] bitin,
  output  a_output,
  output  b_output,
  output  c_output,
  output  d_output,
  output  e_output,
  output  f_output,
  output  g_output
);

  assign a_output = !((!bitin[2] && !bitin[0]) || (bitin[3] && !bitin[0]) || (!bitin[3] && bitin[1]) || (bitin[2] && bitin[1]) || (bitin[3] && !bitin[2] && !bitin[1]) || (!bitin[3] && bitin[2] && bitin[0]));
  assign b_output = !((!bitin[2] && !bitin[1]) || (!bitin[2] && !bitin[0]) || (!bitin[3] && !bitin[1] && !bitin[0]) || (!bitin[3] && bitin[1] && bitin[0]) || (bitin[3] && !bitin[1] && bitin[0]));
  assign c_output = !((!bitin[2] && !bitin[1]) || (!bitin[2] && bitin[0]) || (!bitin[1] && bitin[0]) || (!bitin[3] && bitin[2]) || (bitin[3] && !bitin[2]));
  assign d_output = !((bitin[3] && !bitin[1]) || (!bitin[3] && !bitin[2] && !bitin[0]) || (!bitin[2] && bitin[1] && bitin[0]) || (bitin[2] && !bitin[1] && bitin[0]) || (bitin[2] && bitin[1] && !bitin[0]));
  assign e_output = !((!bitin[2] && !bitin[0]) || (bitin[1] && !bitin[0]) || (bitin[3] && bitin[1]) || (bitin[3] && bitin[2]));
  assign f_output = !((!bitin[1] && !bitin[0]) || (bitin[2] && !bitin[0]) || (bitin[3] && !bitin[2]) || (bitin[3] && bitin[1]) || (!bitin[3] && bitin[2] && !bitin[1]));
  assign g_output = !((!bitin[2] && bitin[1]) || (bitin[1] && !bitin[0]) || (bitin[3] && !bitin[2]) || (bitin[3] && bitin[0]) || (!bitin[3] && bitin[2] && !bitin[1]));

endmodule
