# SSM
This repository contains synthesizable VHDL descriptions and testbenches for the static segmented multipliers (SSMs) described in our paper:

Antonio G.M. Strollo, Ettore Napoli, Davide De Caro, Nicola Petra, Gerardo Saggese, Gennaro Di Meo, "Approximate Multipliers Using Static Segmentation: Error Analysis and Improvements",
IEEE Transactions on Circuits and Systems I: Regular Papers, 2022

# Folders in the Repository
* unsigned : contains VHDL code for static segmented multipliers with and without error correction
* signed : containd two subfolders:
   * proposed_segmentation : VHDL code for signed SSMs using the segmentation proposed in our work, with and without error correction.
   * modulus_sign_corrected: VHDL code for signed SSMs obtained by transforming the operands in sign-modulus representation, multiplying the modules of the operand with an unsigned SSM and transforming the results in 2’s complements representation.


# License and Citation

The VHDL source code is released under the BSD 2-Clause license.(Refer to LICENSE file).

Please cite our paper in your publications, if the code in this repository helps your research:

Antonio G.M. Strollo, Ettore Napoli, Davide De Caro, Nicola Petra, Gerardo Saggese, Gennaro Di Meo, "Approximate Multipliers Using Static Segmentation: Error Analysis and Improvements",
IEEE Transactions on Circuits and Systems I: Regular Papers, 2022

Contact antonio.strollo(at)unina.it for questions.
