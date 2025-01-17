# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 96
  STS_DATA_WIDTH 32
} {
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 96 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 96 DIN_FROM 8 DIN_TO 8
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 96 DIN_FROM 31 DIN_TO 16
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 96 DIN_FROM 71 DIN_TO 32
} {
  din hub_0/cfg_data
}

# Create port_selector
cell pavel-demin:user:port_selector selector_0 {
  DOUT_WIDTH 16
} {
  cfg slice_1/dout
  din /adc_0/m_axis_tdata
}

# Create axis_constant
cell pavel-demin:user:axis_constant phase_0 {
  AXIS_TDATA_WIDTH 40
} {
  cfg_data slice_3/dout
  aclk /pll_0/clk_out1
}

# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_0 {
  DDS_CLOCK_RATE 122.88
  SPURIOUS_FREE_DYNAMIC_RANGE 138
  FREQUENCY_RESOLUTION 0.2
  PHASE_INCREMENT Streaming
  HAS_PHASE_OUT false
  PHASE_WIDTH 30
  OUTPUT_WIDTH 24
  DSP48_USE Minimal
  NEGATIVE_SINE true
  RESYNC true
} {
  S_AXIS_PHASE phase_0/M_AXIS
  aclk /pll_0/clk_out1
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

for {set i 0} {$i <= 1} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_0/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 16
    P_WIDTH 24
  } {
    A dds_slice_$i/dout
    B selector_0/dout
    CLK /pll_0/clk_out1
  }

  # Create axis_variable
  cell pavel-demin:user:axis_variable rate_$i {
    AXIS_TDATA_WIDTH 16
  } {
    cfg_data slice_2/dout
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Programmable
    MINIMUM_RATE 40
    MAXIMUM_RATE 5120
    FIXED_OR_INITIAL_RATE 640
    INPUT_SAMPLE_FREQUENCY 122.88
    CLOCK_FREQUENCY 122.88
    INPUT_DATA_WIDTH 24
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 32
    USE_XTREME_DSP_SLICE false
    HAS_ARESETN true
  } {
    s_axis_data_tdata mult_$i/P
    s_axis_data_tvalid const_0/dout
    S_AXIS_CONFIG rate_$i/M_AXIS
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 2
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.6474608535e-08, -4.7302195930e-08, -7.8619468076e-10, 3.0921189871e-08, 1.8608837232e-08, 3.2734022251e-08, -6.2813438189e-09, -1.5221363991e-07, -8.3032953559e-08, 3.1439829734e-07, 3.0552900504e-07, -4.7396324870e-07, -7.1323740619e-07, 5.4707476786e-07, 1.3341171590e-06, -4.1393271599e-07, -2.1496782582e-06, -6.7769353338e-08, 3.0742601185e-06, 1.0366765715e-06, -3.9428070248e-06, -2.5909585490e-06, 4.5135845246e-06, 4.7460225319e-06, -4.4910558070e-06, -7.3953978786e-06, 3.5707408445e-06, 1.0285546038e-05, -1.5032224453e-06, -1.3015815434e-05, -1.8313444384e-06, 1.5072320650e-05, 6.3521132941e-06, -1.5899576427e-05, -1.1727813184e-05, 1.5005323291e-05, 1.7365093303e-05, -1.2089910213e-05, -2.2458022005e-05, 7.1673633916e-06, 2.6093058018e-05, -6.6389116544e-07, -2.7418691729e-05, -6.5473442360e-06, 2.5854600003e-05, 1.3198330110e-05, -2.1309361735e-05, -1.7782206252e-05, 1.4361810624e-05, 1.8811515648e-05, -6.3566406461e-06, -1.5155979368e-05, -6.3247080943e-07, 6.4130448230e-06, 4.0040582068e-06, 6.7546397959e-06, -1.0026074055e-06, -2.2393312940e-05, -1.0760842920e-05, 3.7217184434e-05, 3.2690283793e-05, -4.6839875203e-05, -6.4629245773e-05, 4.6239001154e-05, 1.0436232686e-04, -3.0525157948e-05, -1.4740012610e-04, -4.1219698477e-06, 1.8711256488e-04, 5.9452347683e-05, -2.1528991520e-04, -1.3425249804e-04, 2.2313567651e-04, 2.2375017156e-04, -2.0262013024e-04, -3.1950057315e-04, 1.4803738125e-04, 4.0989148374e-04, -5.7537086900e-05, -4.8132818219e-04, -6.5649818729e-05, 5.2004965910e-04, 2.1257912313e-04, -5.1442095551e-04, -3.6885882761e-04, 4.5729416912e-04, 5.1576895071e-04, -3.4835026230e-04, -6.3263165645e-04, 1.9558527632e-04, 6.9991497630e-04, -1.5808526144e-05, -7.0293422773e-04, -1.6629328762e-04, 6.3560456533e-04, 3.2068673279e-04, -5.0363032844e-04, -4.1607263761e-04, 3.2646656336e-04, 4.2520826054e-04, -1.3744582074e-04, -3.3090412765e-04, -1.8384678041e-05, 1.3189799213e-04, 8.8910161182e-05, 1.5233898500e-04, -2.1947620222e-05, -4.7890099404e-04, -2.2611987722e-04, 7.8125561143e-04, 6.8011510442e-04, -9.7341268920e-04, -1.3369440637e-03, 9.5707198274e-04, 2.1574180007e-03, -6.3274475096e-04, -3.0612079709e-03, -8.6312096489e-05, 3.9259517547e-03, 1.2584739205e-03, -4.5913883984e-03, -2.8979884036e-03, 4.8688805659e-03, 4.9608225128e-03, -4.5560763256e-03, -7.3338396684e-03, 3.4557999231e-03, 9.8287225977e-03, -1.3976559014e-03, -1.2181437284e-02, -1.7396234513e-03, 1.4056850557e-02, 6.0061144608e-03, -1.5059808596e-02, -1.1365595088e-02, 1.4742813384e-02, 1.7680205017e-02, -1.2613964567e-02, -2.4703438754e-02, 8.1283099644e-03, 3.2073997143e-02, -6.4577008839e-04, -3.9302054798e-02, -1.0686996220e-02, 4.5719765638e-02, 2.7237877738e-02, -5.0304069016e-02, -5.1693673194e-02, 5.1004633533e-02, 9.0534093654e-02, -4.1604028747e-02, -1.6368908068e-01, -1.0763878172e-02, 3.5633171189e-01, 5.5470627800e-01, 3.5633171189e-01, -1.0763878172e-02, -1.6368908068e-01, -4.1604028747e-02, 9.0534093654e-02, 5.1004633533e-02, -5.1693673194e-02, -5.0304069016e-02, 2.7237877738e-02, 4.5719765638e-02, -1.0686996220e-02, -3.9302054798e-02, -6.4577008839e-04, 3.2073997143e-02, 8.1283099644e-03, -2.4703438754e-02, -1.2613964567e-02, 1.7680205017e-02, 1.4742813384e-02, -1.1365595088e-02, -1.5059808596e-02, 6.0061144608e-03, 1.4056850557e-02, -1.7396234513e-03, -1.2181437284e-02, -1.3976559014e-03, 9.8287225977e-03, 3.4557999231e-03, -7.3338396684e-03, -4.5560763256e-03, 4.9608225128e-03, 4.8688805659e-03, -2.8979884036e-03, -4.5913883984e-03, 1.2584739205e-03, 3.9259517547e-03, -8.6312096489e-05, -3.0612079709e-03, -6.3274475096e-04, 2.1574180007e-03, 9.5707198274e-04, -1.3369440637e-03, -9.7341268920e-04, 6.8011510442e-04, 7.8125561143e-04, -2.2611987722e-04, -4.7890099404e-04, -2.1947620222e-05, 1.5233898500e-04, 8.8910161182e-05, 1.3189799213e-04, -1.8384678041e-05, -3.3090412765e-04, -1.3744582074e-04, 4.2520826054e-04, 3.2646656336e-04, -4.1607263761e-04, -5.0363032844e-04, 3.2068673279e-04, 6.3560456533e-04, -1.6629328762e-04, -7.0293422773e-04, -1.5808526144e-05, 6.9991497630e-04, 1.9558527632e-04, -6.3263165645e-04, -3.4835026230e-04, 5.1576895071e-04, 4.5729416912e-04, -3.6885882761e-04, -5.1442095551e-04, 2.1257912313e-04, 5.2004965910e-04, -6.5649818729e-05, -4.8132818219e-04, -5.7537086900e-05, 4.0989148374e-04, 1.4803738125e-04, -3.1950057315e-04, -2.0262013024e-04, 2.2375017156e-04, 2.2313567651e-04, -1.3425249804e-04, -2.1528991520e-04, 5.9452347683e-05, 1.8711256488e-04, -4.1219698477e-06, -1.4740012610e-04, -3.0525157948e-05, 1.0436232686e-04, 4.6239001154e-05, -6.4629245773e-05, -4.6839875203e-05, 3.2690283793e-05, 3.7217184434e-05, -1.0760842920e-05, -2.2393312940e-05, -1.0026074055e-06, 6.7546397959e-06, 4.0040582068e-06, 6.4130448230e-06, -6.3247080943e-07, -1.5155979368e-05, -6.3566406461e-06, 1.8811515648e-05, 1.4361810624e-05, -1.7782206252e-05, -2.1309361735e-05, 1.3198330110e-05, 2.5854600003e-05, -6.5473442360e-06, -2.7418691729e-05, -6.6389116544e-07, 2.6093058018e-05, 7.1673633916e-06, -2.2458022005e-05, -1.2089910213e-05, 1.7365093303e-05, 1.5005323291e-05, -1.1727813184e-05, -1.5899576427e-05, 6.3521132941e-06, 1.5072320650e-05, -1.8313444384e-06, -1.3015815434e-05, -1.5032224453e-06, 1.0285546038e-05, 3.5707408445e-06, -7.3953978786e-06, -4.4910558070e-06, 4.7460225319e-06, 4.5135845246e-06, -2.5909585490e-06, -3.9428070248e-06, 1.0366765715e-06, 3.0742601185e-06, -6.7769353338e-08, -2.1496782582e-06, -4.1393271599e-07, 1.3341171590e-06, 5.4707476786e-07, -7.1323740619e-07, -4.7396324870e-07, 3.0552900504e-07, 3.1439829734e-07, -8.3032953559e-08, -1.5221363991e-07, -6.2813438189e-09, 3.2734022251e-08, 1.8608837232e-08, 3.0921189871e-08, -7.8619468076e-10, -4.7302195930e-08, -1.6474608535e-08}
  COEFFICIENT_WIDTH 24
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 2
  NUMBER_PATHS 1
  SAMPLE_FREQUENCY 3.072
  CLOCK_FREQUENCY 122.88
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 25
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 3
  TDATA_REMAP {tdata[23:0]}
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create floating_point
cell xilinx.com:ip:floating_point fp_0 {
  OPERATION_TYPE Fixed_to_float
  A_PRECISION_TYPE.VALUE_SRC USER
  C_A_EXPONENT_WIDTH.VALUE_SRC USER
  C_A_FRACTION_WIDTH.VALUE_SRC USER
  A_PRECISION_TYPE Custom
  C_A_EXPONENT_WIDTH 2
  C_A_FRACTION_WIDTH 22
  RESULT_PRECISION_TYPE Single
  HAS_ARESETN true
} {
  S_AXIS_A subset_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS fp_0/M_AXIS_RESULT
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 64
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 4096
  ALWAYS_READY TRUE
} {
  S_AXIS conv_1/M_AXIS
  M_AXIS hub_0/S00_AXIS
  read_count hub_0/sts_data
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}
