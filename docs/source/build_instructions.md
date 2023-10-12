# Build instructions

## Source code

The source code for the reference designs is managed on this Github repository:

* [https://github.com/fpgadeveloper/ethernet-fmc-axi-eth](https://github.com/fpgadeveloper/ethernet-fmc-axi-eth)

To get the code, you can follow the link and use the **Download ZIP** option, or you can clone it
using this command:
```
git clone https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
```

## License requirements

The designs for the boards listed below **require a license** to build. To build the designs for these boards,
you will need to either buy a license or download a 30-day evaluation license for Vivado ML Enterprise Edition:

* [KC705]
* [KCU105]
* [VC707]
* [VC709]
* [VCU108]
* [VCU118]
* [ZC706]
* [ZCU102]

The designs for all of the remaining [target boards](supported_carriers) can be built with the Vivado ML Standard 
Edition **without a license**. That includes the following boards:

* [AC701]
* [PicoZed FMC Carrier v2]
* [ZedBoard]
* [UltraZed EV carrier]
* [ZC702]

## Target designs

This repo contains several designs that target the various supported development boards and their
FMC connectors. The table below lists the target design name, the Ethernet ports supported by the design and 
the FMC connector on which to connect the mezzanine card.

| Target design     | Standalone app | PetaLinux | Eth ports           | Target board and connector  |
|-------------------|----------------|-----------|---------------------|-----------------------------|
| `ac701`           | YES            | YES       | PORT0,1,2,3         | [AC701]                     |
| `kc705_hpc`       | YES            | YES       | PORT0,1,2,3         | [KC705], HPC connector      |
| `kc705_lpc`       | YES            | YES       | PORT0,1,2,3         | [KC705], LPC connector      |
| `kc705_lpc_hpc`   | YES            | YES       | PORT0,1,2,3,4,5,6,7 | [KC705], HPC+LPC connector  |
| `kcu105_dual`     | YES            | YES       | PORT0,1,2,3,4,5,6,7 | [KCU105], HPC+LPC connector |
| `kcu105_hpc`      | YES            | YES       | PORT0,1,2,3         | [KCU105], HPC connector     |
| `kcu105_lpc`      | YES            | YES       | PORT0,1,3           | [KCU105], LPC connector     |
| `pz_7015`         | YES            | YES       | PORT0,1,2,3         | [PicoZed FMC Carrier v2]    |
| `pz_7020`         | YES            | YES       | PORT0,1,2,3         | [PicoZed FMC Carrier v2]    |
| `pz_7030`         | YES            | YES       | PORT0,1,2,3         | [PicoZed FMC Carrier v2]    |
| `uzev`            | YES            | YES       | PORT0,1,2,3         | [UltraZed EV carrier]       |
| `vc707_hpc1`      | YES            | NO        | PORT0,1,2,3         | [VC707], HPC1 connector     |
| `vc707_hpc2`      | YES            | NO        | PORT0,1,2,3         | [VC707], HPC2 connector     |
| `vc707_hpc2_hpc1` | YES            | NO        | PORT0,1,2,3,4,5,6,7 | [VC707], HPC2+HPC1 connector |
| `vc709`           | YES            | NO        | PORT0,1,2,3         | [VC709]                     |
| `vcu108_hpc0`     | YES            | NO        | PORT0,1,2,3         | [VCU108], HPC0 connector    |
| `vcu108_hpc1`     | YES            | NO        | PORT0,1,2,3         | [VCU108], HPC1 connector    |
| `vcu118`          | YES            | YES       | PORT0,1,2,3         | [VCU118]                    |
| `zc702_lpc1`      | YES            | YES       | PORT0,1,2,3         | [ZC702], LPC1 connector     |
| `zc702_lpc2`      | YES            | YES       | PORT0,1,2,3         | [ZC702], LPC2 connector     |
| `zc702_lpc2_lpc1` | YES            | YES       | PORT0,1,2,3,4,5,6,7 | [ZC702], LPC2+LPC1 connector |
| `zc706_lpc`       | YES            | YES       | PORT0,1,2,3         | [ZC706], LPC connector      |
| `zcu102_hpc0`     | YES            | YES       | PORT0,1,2,3         | [ZCU102], HPC0 connector    |
| `zcu102_hpc1`     | YES            | YES       | PORT0,1             | [ZCU102], HPC1 connector    |
| `zedboard`        | YES            | YES       | PORT0,1,2,3         | [ZedBoard]                  |

## Windows users

Windows users will be able to build the Vivado projects and compile the standalone applications,
however Linux is required to build the PetaLinux projects. 

```{tip} If you wish to build the PetaLinux projects,
we recommend that you build the entire project (including the Vivado project) on a machine (either 
physical or virtual) running one of the [supported Linux distributions].
```

### Build Vivado project in Windows

1. Download the repo as a zip file and extract the files to a directory
   on your hard drive --OR-- clone the repo to your hard drive
2. Open Windows Explorer, browse to the repo files on your hard drive.
3. In the `Vivado` directory, you will find multiple batch files (.bat).
   Double click on the batch file that corresponds to the target design you wish to build.
   This will generate a Vivado project for your target design and it will be located in
   the folder `Vivado/<target>`.
4. Run Vivado and open the project that was just created.
5. Click Generate bitstream.
6. When the bitstream is successfully generated, select **File->Export->Export Hardware**.
   In the window that opens, tick **Include bitstream** and use the default name and location
   for the XSA file.

### Build Vitis workspace in Windows

1. Return to Windows Explorer and browse to the Vitis directory in the repo.
2. Double click the `build-vitis.bat` batch file. The batch file will run the
   `tcl/build-vitis.tcl` script and build the Vitis workspace containing the hardware
   platform and the software application for the target design that you built earlier.

## Linux users

These projects can be built using a machine (either physical or virtual) with one of the 
[supported Linux distributions].

```{tip} The build steps can be completed in the order shown below, or
you can go directly to the [build PetaLinux](#build-petalinux-project-in-linux) instructions below
to build the Vivado and PetaLinux projects with a single command.
```

### Build Vivado project in Linux

1. Open a command terminal and launch the setup script for Vivado:
   ```
   source <path-to-vivado-install>/2022.1/settings64.sh
   ```
2. Clone the Git repository and `cd` into the `Vivado` folder of the repo:
   ```
   git clone https://github.com/fpgadeveloper/ethernet-fmc-axi-eth.git
   cd ethernet-fmc-axi-eth/Vivado
   ```
3. Run make to create the Vivado project for the target board. You must replace `<target>` with a valid
   target (alternatively, skip to step 5):
   ```
   make project TARGET=<target>
   ```
   Valid targets are: 
   `ac701`,
   `kc705_hpc`,
   `kc705_lpc`,
   `kc705_lpc_hpc`,
   `kcu105_dual`,
   `kcu105_hpc`,
   `kcu105_lpc`,
   `pz_7015`,
   `pz_7020`,
   `pz_7030`,
   `uzev`,
   `vc707_hpc1`,
   `vc707_hpc2`,
   `vc707_hpc2_hpc1`,
   `vc709`,
   `vcu108_hpc0`,
   `vcu108_hpc1`,
   `vcu118`,
   `zc702_lpc1`,
   `zc702_lpc2`,
   `zc702_lpc2_lpc1`,
   `zc706_lpc`,
   `zcu102_hpc0`,
   `zcu102_hpc1`,
   `zedboard`.
   That will create the Vivado project and block design without generating a bitstream or exporting to XSA.
4. Open the generated project in the Vivado GUI and click **Generate Bitstream**. Once the build is
   complete, select **File->Export->Export Hardware** and be sure to tick **Include bitstream** and use
   the default name and location for the XSA file.
5. Alternatively, you can create the Vivado project, generate the bitstream and export to XSA (steps 3 and 4),
   all from a single command:
   ```
   make xsa TARGET=<target>
   ```
   
### Build Vitis workspace in Linux

The following steps are required if you wish to build and run the [standalone application](stand_alone). You can
skip to the following section if you instead want to use PetaLinux. You are not required to have built the
Vivado design before following these steps, as the Makefile triggers the Vivado build for the corresponding
design if it has not already been done.

1. Launch the setup script for Vivado (only if you skipped the Vivado build steps above):
   ```
   source <path-to-vivado-install>/2022.1/settings64.sh
   ```
2. Launch the setup scripts for Vitis:
   ```
   source <path-to-vitis-install>/2022.1/settings64.sh
   ```
3. To build the Vitis workspace, `cd` to the Vitis directory in the repo,
   then run make to create the Vitis workspace and compile the standalone application:
   ```
   cd ethernet-fmc-axi-eth/Vitis
   make workspace TARGET=<target>
   ```

### Build PetaLinux project in Linux

These steps will build the PetaLinux project for the target design. You are not required to have built the
Vivado design before following these steps, as the Makefile triggers the Vivado build for the corresponding
design if it has not already been done.

1. Launch the setup script for Vivado (only if you skipped the Vivado build steps above):
   ```
   source <path-to-vivado-install>/2022.1/settings64.sh
   ```
2. Launch PetaLinux by sourcing the `settings.sh` bash script, eg:
   ```
   source <path-to-petalinux-install>/2022.1/settings.sh
   ```
3. Build the PetaLinux project for your specific target platform by running the following
   command, replacing `<target>` with a valid value from below:
   ```
   cd PetaLinux
   make petalinux TARGET=<target>
   ```
   Valid targets are: 
   `ac701`,
   `kc705_hpc`,
   `kc705_lpc`,
   `kc705_lpc_hpc`,
   `kcu105_dual`,
   `kcu105_hpc`,
   `kcu105_lpc`,
   `pz_7015`,
   `pz_7020`,
   `pz_7030`,
   `uzev`,
   `vcu118`,
   `zc702_lpc1`,
   `zc702_lpc2`,
   `zc706_lpc`,
   `zcu102_hpc0`,
   `zcu102_hpc1`,
   `zedboard`.
   Note that if you skipped the Vivado build steps above, the Makefile will first generate and
   build the Vivado project, and then build the PetaLinux project.

### PetaLinux offline build

If you need to build the PetaLinux projects offline (without an internet connection), you can
follow these instructions.

1. Download the sstate-cache artefacts from the Xilinx downloads site (the same page where you downloaded
   PetaLinux tools). There are four of them:
   * aarch64 sstate-cache (for ZynqMP designs)
   * arm sstate-cache (for Zynq designs)
   * microblaze sstate-cache (for Microblaze designs)
   * Downloads (for all designs)
2. Extract the contents of those files to a single location on your hard drive, for this example
   we'll say `/home/user/petalinux-sstate`. That should leave you with the following directory 
   structure:
   ```
   /home/user/petalinux-sstate
                             +---  aarch64
                             +---  arm
                             +---  downloads
                             +---  microblaze
   ```
3. Create a text file called `offline.txt` that contains a single line of text. The single line of text
   should be the path where you extracted the sstate-cache files. In this example, the contents of 
   the file would be:
   ```
   /home/user/petalinux-sstate
   ```
   It is important that the file contain only one line and that the path is written with NO TRAILING 
   FORWARD SLASH.

Now when you use `make` to build the PetaLinux projects, they will be configured for offline build.

[supported Linux distributions]: https://docs.xilinx.com/r/2022.1-English/ug1144-petalinux-tools-reference-guide/Setting-Up-Your-Environment
[Ethernet FMC]: https://ethernetfmc.com
[AC701]: https://www.xilinx.com/ac701
[KC705]: https://www.xilinx.com/kc705
[VC707]: https://www.xilinx.com/vc707
[VC709]: https://www.xilinx.com/vc709
[VCU108]: https://www.xilinx.com/vcu108
[VCU118]: https://www.xilinx.com/vcu118
[KCU105]: https://www.xilinx.com/kcu105
[ZC702]: https://www.xilinx.com/zc702
[ZC706]: https://www.xilinx.com/zc706
[ZCU111]: https://www.xilinx.com/zcu111
[ZCU208]: https://www.xilinx.com/zcu208
[Trenz TEBF0808]: https://shop.trenz-electronic.de/en/TEBF0808-04A-UltraITX-Baseboard-for-Trenz-Electronic-TE080X-UltraSOM
[PicoZed FMC Carrier v2]: https://www.avnet.com/wps/portal/silica/products/product-highlights/2016/xilinx-picozed-fmc-carrier-card-v2/
[ZedBoard]: https://digilent.com/reference/programmable-logic/zedboard/start
[UltraZed EG PCIe Carrier]: https://www.xilinx.com/products/boards-and-kits/1-mb9rqb.html
[UltraZed EV carrier]: https://www.xilinx.com/products/boards-and-kits/1-y3n9v1.html
[ZCU104]: https://www.xilinx.com/zcu104
[ZCU102]: https://www.xilinx.com/zcu102
[ZCU106]: https://www.xilinx.com/zcu106
[PYNQ-ZU]: https://www.tulembedded.com/FPGA/ProductsPYNQ-ZU.html


