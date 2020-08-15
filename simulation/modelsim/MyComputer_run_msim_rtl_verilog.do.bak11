transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Kevin.E/Google\ Drive/UNI/Year\ 3\ Sem\ 1/Digital\ Sysem\ Design/Project/Project {C:/Users/Kevin.E/Google Drive/UNI/Year 3 Sem 1/Digital Sysem Design/Project/Project/AuxMod.v}
vlog -vlog01compat -work work +incdir+C:/Users/Kevin.E/Google\ Drive/UNI/Year\ 3\ Sem\ 1/Digital\ Sysem\ Design/Project/Project {C:/Users/Kevin.E/Google Drive/UNI/Year 3 Sem 1/Digital Sysem Design/Project/Project/mycomputer.v}
vlog -vlog01compat -work work +incdir+C:/Users/Kevin.E/Google\ Drive/UNI/Year\ 3\ Sem\ 1/Digital\ Sysem\ Design/Project/Project {C:/Users/Kevin.E/Google Drive/UNI/Year 3 Sem 1/Digital Sysem Design/Project/Project/ROM.v}
vlog -vlog01compat -work work +incdir+C:/Users/Kevin.E/Google\ Drive/UNI/Year\ 3\ Sem\ 1/Digital\ Sysem\ Design/Project/Project {C:/Users/Kevin.E/Google Drive/UNI/Year 3 Sem 1/Digital Sysem Design/Project/Project/CPU.v}

vlog -vlog01compat -work work +incdir+C:/Users/Kevin.E/Google\ Drive/UNI/Year\ 3\ Sem\ 1/Digital\ Sysem\ Design/Project/Project {C:/Users/Kevin.E/Google Drive/UNI/Year 3 Sem 1/Digital Sysem Design/Project/Project/test_mycomputer.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  test_mycomputer

add wave *
view structure
view signals
run -all
