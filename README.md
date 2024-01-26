# OFDB: Open Firmware Dataset Builder


  - [About](#about)
  - [Structure of this Project](#structure-of-this-project)
  - [Release](#release)
  - [Usage](#usage)
    - [Prepare the Build Environment](#prepare-the-build-environment)
    - [Build the Dataset](#build-the-dataset)
  - [Dataset Overview](#dataset-overview)
    - [Dataset Tree](#dataset-tree)
    - [Firmware Metadata](#firmware-metadata)
  - [Existing Dataset Integration](#existing-dataset-integration)
    - [P2IM Real Firmware](#p2im-real-firmware)
  - [How to Contribute](#how-to-contribute)


## About

This project seeks to promote and enable reproducible results in the field of firmware analysis research. It provides a reproducible way to build a firmware image dataset based on full or partial open source firmware. This repository contributes to this task in the following way:


- 1: Provides the required material (tools and sources code) to build each firmware image contains in the firmware dataset. The material come from third parties (industry, academia, and hobbyist...) and it is centralised and archived in a public repository.

- 2: Provides a collection of Scripts and Makefiles to build automatically each firmware image of the firmware dataset.

- 3: Provides additional standardised metadata about each firmware image contains in the firmware dataset, as memory load data and build data.


This project exists for various reasons, which are principally the reproducibility of the builds, the full control over the build steps, the metadata collection about firmware images, and the fast deployment of a functional firmware build environment to test new ideas in the field of firmware analysis. The start point of this project is based on the observation that many research in firmware analysis using open source firmware provide only the final firmware in binary blob format without the build material and build steps; or sometimes with the full-build environment containing modifications partially documented and specific to the research topic.


Ensure a firmware build identically over the time requires the build material frozen in a specific version. Gather and setup this material can be time consuming, also the material available on the WEB can disappear over the time, or the build material can be obsolete and not compatible with the current supported systems. For example, a firmware build can require an outdated graphical IDE version working only on an old Operating System, which forces to deploy a virtual machine and make it more difficult to customise. To get around all these pitfalls, the Open Firmware Dataset Builder rely on an archived frozen material and custom Makefiles to build the firmware dataset in a single, customisable, and reproducible build environment trying to avoid heavy virtualisation and heavy build tools.


Firmware building is an important step in firmware analysis research because it can be used to perform various tasks before/after/at build time, as: source code analysis, source code patching, customisation of the compilation step, or final image(s) binary analysis. As mentioned previously setup the build environment to produce a firmware image can be tedious, therefore rely on a reproducible and customisable environment to take full control over this step add high value to implement and test new ideas with a minimum effort invested in build environment deployment.


Another goal of this project is to provide important knowledge about each firmware image build. The first is related to firmware image(s) loading and inform on which processor architecture and model each firmware image is executed, where each part of firmware image(s) is loaded in memory, and where the execution start for each processor of the target board. For example, this data add value for firmware emulation at scale since you can rely on a standardised data format to know how to load the firmware image(s) in the emulator. The second is related to firmware build data, this project implement data collection after each image build step to inform about build tools and versions, firmware and libraries source code versions and origin location.




## Structure of this Project

The Open Firmware Dataset project is split in three repositories:

- open-firmware-dataset-archive (OFDA): Provide the frozen material (tools and sources code) required to build the firmware dataset. This project is based on the [archive.org](https://archive.org) platform.
- open-firmware-dataset-builder (OFDB): Provide Scripts and Makefiles to build the firmware dataset, and documentation about the Open Firmware Dataset project.
- [open-firmware-dataset (OFD)](https://sourceforge.net/projects/open-firmware-dataset/files/): The releases of the firmware dataset build containing only firmware images and metadata.




## Release

The releases of this project are hosted on [sourceforge.net](https://sourceforge.net) at the following URL.

- [https://sourceforge.net/projects/open-firmware-dataset/files/](https://sourceforge.net/projects/open-firmware-dataset/files/)


## Usage

### Prepare the Build Environment

Clone this repository.

```text
$ git clone https://github.com/VincentDary/open-firmware-dataset-builder
```

To prepare the build environment required to build the firmware dataset run the script named `build_env.sh`. This script creates a directory tree at the root of the repository.

```text
$ ./open-firmware-dataset-builder/scripts/build_env.sh --archive-location=archive.org
```

The `--archive-location` option selects the download location of the build material. This option can take the following values:

- An existing archive directory: A path on the local file system to the required building material. In this case, the script `build_env.sh` create a symbolic to this directory.

- `archive.org`: The build material is downloaded from a copy archived on the archive.org platform. This is the recommended way to download the requirements for the build of the dataset. Note that the download from archive.org can be slow, since the bandwidth is restrained.

- `original-source`: The build material is downloaded from the original source URL of each archive. This download method is not recommended because URLs can disappear with the time and lead to an incomplete build material. In addition, security countermeasures on some server can block the archive download because the script can be flagged as a bot. Note that the download from the original source is the fastest. This download option exists for development purpose in order to retrieve the build material before archiving.


### Build the Dataset

To build the firmware dataset change the directory to `builders` and run `make`.

```text
$ cd ./open-firmware-dataset-builder/builders
$ make
```

The firmware builds are available in the `builds` directory at the root of the repository.

```text
$ ls -l ../builds
```


## Dataset Overview

### Dataset Tree

The firmware dataset is built under the `builds ` directory. Each built firmware has a directory at the root of the `builds` directory. It contains the firmware image(s), a file named `firmware_metadata.json` containing metadata about the firmware, and potentially other files like `*.map` and `*.elf`. The following output shows a truncated overview of the `builds` directory.

```text
$ tree open-firmware-dataset-builder/builds
firmware-dataset-builder/builds/
├── arduino-due-AT91SAM3X8E-car-controller
│         ├── car_controller.ino.bin
│         ├── car_controller.ino.elf
│         ├── car_controller.ino.map
│         └── firmware_metadata.json
├── arduino-due-AT91SAM3X8E-heat-press-RiS3-lab
│         ├── firmware_metadata.json
│         ├── HeatPress.ino.bin
│         ├── HeatPress.ino.elf
│         └── HeatPress.ino.map
├── blue-pill-STM32F103C8T6-inverted-pendulum-robot
│         ├── firmware_metadata.json
│         ├── inverted_pendulum.bin
│         ├── inverted_pendulum.elf
│         └── inverted_pendulum.map

[...]
```

### Firmware Metadata

For each firmware of the dataset, metadata is collected and saved in a file named `firmware_metadata.json` at the root of each firmware directory. Below an example of metadata produce during the dataset build.

```json
{
    "board": "blue-pill",
    "load_meta": [
        {
            "processor_id": "main",
            "processor": "arm",
            "processor_variant": "v7",
            "processor_model": "STM32F103C8T6",
            "entry_point": 134232381,
            "loads": [
                {
                    "file": "inverted_pendulum.bin",
                    "file_offset": 0,
                    "length": 24008,
                    "base_address": 134217728
                }
            ]
        }
    ],
    "firmware_build_meta": [
        {
            "filename": "inverted_pendulum.bin",
            "file_size": 24008,
            "sha1": "dd16ccd2b03857642dd85b57de4c13f8e30a23d2",
            "endian": "little",
            "operating_system": null,
            "compiler": "gcc",
            "toolchain": "gcc-arm-none-eabi-7-2017-q4-major-linux",
            "processor": "arm",
            "processor_variant": "v7",
            "processor_model": "STM32F103C8T6",
            "entry_point": 134232381,
            "source_code": [
                {
                    "url": "https://github.com/mbocaneg/Inverted-Pendulum-Robot.git",
                    "git_commit": "b04c16c593440ca10ebf91823280c426d7749872"
                }
            ]
        }
    ]
}
```

The field `board` provides the board name the firmware image(s) target. This information is filled when the board is generic, however, embedded system is often based on custom hardware, in this case the value of this field is `custom`.


The field `load_meta` is a list of structured items which provides for each processor of the board: a processor identifier `processor_id`, the processor characteristics `processor`/`processor_variant`/`processor_model`, the binary blobs to load in physical memory `load_meta.loads`, and the location in physical memory of the processor execution entry point `entry_point`. The field `load_meta.loads` is a list of structured items which informs where to load in physical memory each part of the firmware image(s). Each of these items have a field `file` which references the relative file path of a firmware image at the root of the firmware directory, and specify in this specific file a binary block begins at `file_offset` of size `length` which must be loaded in physical memory at the location specified by `base_address`.


The field `firmware_build_meta` is a list of structured items which provides build related data (firmware image hash, toolchains, compiler, target processor, image entry point if it is relevant) about each image which is part of the firmware. Each item has a field `source_code` which is a list of structured items which provides information of each source code used to build the image as the URL of the project if exist and a Git commit if the project is a Git repository.




## Existing Dataset Integration

At the moment, OFD include only a modified version of the "P2IM Real Firmware" dataset based on the original sources. Another dataset integration is still in progress.


### P2IM Real Firmware

The "real firmware" dataset used in the P2IM paper is part of the Open Firmware Dataset (OFD). Below, a table shows the name mapping between P2IM firmware names and OFD build directory names. The firmware dataset from P2IM research has been entirely reviewed before integration, in order to used the original code sources and build tools, not the material provided by the repository of the study.

For each firmware build, the Open Firmware Dataset Builder (OFDB) used the original and non-modified source code of the firmware, and sometimes custom Makefiles for firmware build, in order to avoid the usage of heavy IDE (Atollic True STUDIO...). But with one exception, for the 'Heat_Press' firmware, only available on the Github repository related to this research. It seems to be an equivalent of a proprietary firmware for Controllino PLC, rewritten partially by the researchers to avoid legal issues.

The integration of the P2IM dataset does not include the firmware sources code modifications used in the research. A common code modification is applied to each firmware to start an American Fuzzing Loop server in background for fuzzing purpose, since the goal of this repository is to provide a neutral dataset, these modifications have not been applied. In the same way, for the sake of neutrality, have not been applied modifications related to firmware peripheral usages which have been commented in the source code due to emulation and fuzzing issues (partially or not documented).


| P2IM real firmware name | FDB firmware build directory name                       |
|-------------------------|---------------------------------------------------------|
| CNC                     | STM32F4DISCOVERY-STM32F407VG-grbl-stm32f4               |
| Console                 | frdm-k64f-MK64FN1M0VLL12-riot-os-demo-shell             |
| Drone                   | custom-STM32F103C8-eYSIP-quadcopter                     |
| Gateway                 | nucleo-64-STM32F103RB-demo-standard-firmata             |
| Heat_Press              | arduino-due-AT91SAM3X8E-heat-press-RiS3-Lab             |
| PLC                     | nucleo-144-STM32F429ZI-arduino-modbus-demo-simple-slave |
| Reflow_Oven             | nucleo-64-STM32F103RB-reflow-oven-controller            |
| Robot                   | blue-pill-STM32F103C8T6-inverted-pendulum-robot         |
| Steering_Control        | arduino-due-AT91SAM3X8E-car-controller                  |




## How to Contribute

Any contribution is welcoming.

For contribution related to integration of a new firmware, we recommend following these rules:

- For each firmware integration, add a directory at the root of the directory `builders`, and a Makefile named `Makefile` which must perform the following tasks: copy the build material required for the build in a dedicated directory under the directory `src`, build the firmware image(s) and the associated metadata, and copy the files in a dedicated directory under the directory `builds`.

- Add the download information of the required build material according the following cases.

    * For a simple archive. First, archive the file on the archive.org platform without any modification, or request the archiving of your material by opening an issue in this project. Secondly, add a line in the file `data/url_archives.txt`, in the following format `filename;sha1;url_origin;url_archive.org`.

    * For a Git repository hosted on the Github platform. First add the URL of the repository in the file `data/url_github_repository.txt`. Secondly, archives without any modification the Git repository in `tar.gz` format on the archive.org platform, or request the archiving of your material by opening an issue in this project. Finally, add the archived URL of the Git repository in the file `data/url_archives.txt` by adding a line which takes the following format `filename;sha1;;url_archive.org`.

    * For an archive related to Arduino package (not Git repository), first, archive the file on the archive.org platform without any modification, or request the archiving of your material by opening an issue in this project. Finally, add a line in the file `data/url_archives_arduino.txt`, in the following format `filename;sha1;url_origin;url_archive.org`.

    * If your case is not commented here open an issue to propose a remedy, or a remedy will be found.

- For each new archived file of the build material, add a line in the file `data/archive_files_freeze.txt` in the following format `sha1;path`, where `sha1` is the sha1 of the file  and `path` is the relative file path of the archived file from the root of the `archives` directory. To skip file signature validation add the line in the following format `;path`.

