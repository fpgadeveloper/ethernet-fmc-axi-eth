# AXI Ethernet Reference Designs for Ethernet FMC

## Description

This project demonstrates the use of the Opsero [Quad Gigabit Ethernet FMC](https://ethernetfmc.com "Ethernet FMC") and it supports
several FPGA/MPSoC development boards. The design contains 4 AXI Ethernet blocks configured with DMAs.

![Block diagram](docs/source/images/axi-eth-block-diagram.png "AXI Ethernet block diagram")

Important links:

* The user guide for these reference designs is hosted here: [AXI Ethernet for Ethernet FMC docs](https://axieth.ethernetfmc.com "AXI Ethernet for Ethernet FMC docs")
* To report a bug: [Report an issue](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/issues "Report an issue").
* For technical support: [Contact Opsero](https://opsero.com/contact-us "Contact Opsero").
* To purchase the mezzanine card: [Ethernet FMC order page](https://opsero.com/product/ethernet-fmc "Ethernet FMC order page").

## Requirements

This project is designed for version 2022.1 of the Xilinx tools (Vivado/Vitis/PetaLinux). 
If you are using an older version of the Xilinx tools, then refer to the 
[release tags](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth/tags "releases")
to find the version of this repository that matches your version of the tools.

In order to test this design on hardware, you will need the following:

* Vivado 2022.1
* Vitis 2022.1
* PetaLinux Tools 2022.1
* [Ethernet FMC](https://ethernetfmc.com "Ethernet FMC")
* One of the [supported evaluation boards](https://axieth.ethernetfmc.com/en/latest/supported_carriers.html)
* [Xilinx Soft TEMAC license](https://ethernetfmc.com/getting-a-license-for-the-xilinx-tri-mode-ethernet-mac/ "Xilinx Soft TEMAC license")

### Target boards

#### FPGA boards

* [AC701](https://www.xilinx.com/ac701)
* [KC705](https://www.xilinx.com/kc705)
* [KCU105](https://www.xilinx.com/kcu105)
* [VC707](https://www.xilinx.com/vc707)
* [VC709](https://www.xilinx.com/vc709)
* [VCU108](https://www.xilinx.com/vcu108)
* [VCU118](https://www.xilinx.com/vcu118)

#### Zynq boards

* [PicoZed FMC Carrier v2](https://www.avnet.com/wps/portal/silica/products/product-highlights/2016/xilinx-picozed-fmc-carrier-card-v2/)
* [ZC702](https://www.xilinx.com/zc702)
* [ZC706](https://www.xilinx.com/zc706)
* [ZedBoard](https://digilent.com/reference/programmable-logic/zedboard/start)

#### Zynq UltraScale+ MPSoC boards

* [ZCU102](https://www.xilinx.com/zcu102)
* [UltraZed EV carrier](https://www.xilinx.com/products/boards-and-kits/1-y3n9v1.html)

#### Zynq UltraScale+ RFSoC boards

* [ZCU111](https://www.xilinx.com/zcu111)
* [ZCU208](https://www.xilinx.com/zcu208)

## Contribute

We strongly encourage community contribution to these projects. Please make a pull request if you
would like to share your work:
* if you've spotted and fixed any issues
* if you've added designs for other target platforms

Thank you to everyone who supports us!

## About us

This project was developed by [Opsero Inc.](https://opsero.com "Opsero Inc."),
a tight-knit team of FPGA experts delivering FPGA products and design services to start-ups and tech companies. 
Follow our blog, [FPGA Developer](https://www.fpgadeveloper.com "FPGA Developer"), for news, tutorials and
updates on the awesome projects we work on.

