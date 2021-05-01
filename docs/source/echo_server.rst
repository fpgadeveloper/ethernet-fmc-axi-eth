================================
Stand-alone lwIP Echo Server
================================

These reference designs can be used with the stand-alone lwIP echo server application template that is 
part of Vitis; however, some modifications are required. The lwIP library needs some modifications to be able to 
properly configure the Marvell PHYs (88E1510) that are on the Ethernet FMC. The ``Vitis`` directory of the 
source repository contains a script that can be used to setup a Vitis workspace containing the echo server 
application and the modified lwIP library.

The build script does the following:

#. Creates a Vitis workspace in the ``Vitis`` directory of the source repository.
#. Creates a subdirectory called ``embeddedsw`` to be used as a local software repository
   containing the modified lwIP library.
#. Copies the sources from the ``EmbeddedSw`` directory of the repository to the local 
   software repository (``embeddedsw``), then copies any remaining/unmodified sources
   from the Vitis installation directory into the local software repository.
#. Generates a lwIP Echo Server example application for each exported Vivado design
   that is found in the ``Vivado`` directory. Most users will only have one exported
   Vivado design.

Building the Vitis workspace
================================

To build the Vitis workspace and echo server application, you must first generate
the Vivado project hardware design (the bitstream) and export the hardware.
Once the bitstream is generated and exported, then you can build the
Vitis workspace using the provided ``Vitis/build-vitis.tcl`` script.

Windows users
-------------

To build the Vitis workspace, Windows users can run the ``build-vitis.bat`` file which
launches the Tcl script.

Linux users
-----------

Linux users must use the following commands to run the build script:

.. code-block::

  cd <path-to-repo>/Vitis
  /<path-to-xilinx-tools>/Vitis/2020.2/bin/xsct build-vitis.tcl

Run the application
===================

#. Open Xilinx Vitis.
#. Power up your hardware platform and ensure that the JTAG is
   connected properly.
#. In the Vitis Explorer panel, double-click on the System project that you want to run -
   this will reveal the applications contained in the project. The System project will have 
   the postfix "_system".
#. Now click on the application that you want to run. It should have the postfix "_echo_server".
#. Select the option "Run Configurations" from the drop-down menu contained under the Run
   button on the toolbar (play symbol).
#. Double-click on "Single Application Debug" to create a run configuration for this 
   application. Then click "Run".

The run configuration will first program the FPGA with the bitstream, then load and run the 
application. You can view the UART output of the application in a console window.

UART settings
=============

To receive the UART output of this standalone application, you will need to connect the
USB-UART of the development board to your PC and run a console program such as 
`Putty`_. The following UART settings must be used:

* Microblaze designs: 9600 baud
* Zynq and ZynqMP designs: 115200 baud

How to change the Ethernet port targetted by the application
============================================================

The echo server example design currently can only target one Ethernet port at a time.
Selection of the Ethernet port can be changed by modifying the defines contained in the
``platform_config.h`` file in the application sources. Set ``PLATFORM_EMAC_BASEADDR``
to one of the following values:

* Ethernet FMC Port 0: ``XPAR_AXIETHERNET_0_BASEADDR``
* Ethernet FMC Port 1: ``XPAR_AXIETHERNET_1_BASEADDR``
* Ethernet FMC Port 2: ``XPAR_AXIETHERNET_2_BASEADDR``
* Ethernet FMC Port 3: ``XPAR_AXIETHERNET_3_BASEADDR``


.. _Putty: https://www.putty.org
