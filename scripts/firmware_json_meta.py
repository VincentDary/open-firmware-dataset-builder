################################################################################
#
# Copyright 2023-2024 Vincent Dary
#
# This file is part of open-firmware-dataset-builder (OFDB).
#
# open-firmware-dataset-builder is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# open-firmware-dataset-builder is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# open-firmware-dataset-builder. If not, see <https://www.gnu.org/licenses/>.
#
################################################################################

import json
import argparse


def cmd_firmware_build_meta(cli_args: argparse.Namespace):
    data = {
        'filename': cli_args.filename,
        'file_size': int(cli_args.file_size),
        'sha1': cli_args.sha1,
        'endian': cli_args.endian,
        'operating_system': cli_args.operating_system,
        'compiler': cli_args.compiler,
        'toolchain': cli_args.toolchain,
        'processor': cli_args.processor,
        'processor_variant': cli_args.processor_variant,
        'processor_model': cli_args.processor_model,
        'entry_point': int(cli_args.entry_point, 16),
        'source_code': [
            {'url': src[0], 'git_commit': src[1]} for src in cli_args.src
        ]
    }

    with open(cli_args.out, 'w') as fp:
        json.dump(data, fp, indent=4)


def cmd_firmware_load_meta(cli_args: argparse.Namespace):
    data = {
        'processor_id': cli_args.processor_id,
        'processor': cli_args.processor,
        'processor_variant': cli_args.processor_variant,
        # 'endian': None,
        'processor_model': cli_args.processor_model,
        'entry_point': int(cli_args.entry_point, 16),
        'loads': [
            {
                'file': load[0],
                'file_offset': int(load[1], 16),
                'length': int(load[2]),
                'base_address': int(load[3], 16)
            }
            for load in cli_args.load
        ],

    }

    with open(cli_args.out, 'w') as fp:
        json.dump(data, fp, indent=4)


def cmd_firmware_all_meta(cli_args: argparse.Namespace):
    data = {
        'board': cli_args.board,
        'load_meta': [json.load(open(f[0])) for f in cli_args.load_meta_file],
        'firmware_build_meta': [json.load(open(f[0])) for f in cli_args.firmware_build_meta_file]
    }

    with open(cli_args.out, 'w') as fp:
        json.dump(data, fp, indent=4)


def cli_parse():
    parser = argparse.ArgumentParser(prog='Firmware metadata to JSON')
    subparsers = parser.add_subparsers(help='Firmware file metadata.')

    # firmware_build_meta
    fw_build_meta = subparsers.add_parser('firmware_build_meta', help='a help')
    fw_build_meta.set_defaults(func=cmd_firmware_build_meta)
    fw_build_meta.add_argument('--filename', required=True)
    fw_build_meta.add_argument('--file-size', required=True)
    fw_build_meta.add_argument('--sha1', required=True)
    fw_build_meta.add_argument('--endian', required=True)
    fw_build_meta.add_argument('--operating-system', default=None)
    fw_build_meta.add_argument('--compiler', required=True)
    fw_build_meta.add_argument('--toolchain', required=True)
    fw_build_meta.add_argument('--processor', required=True)
    fw_build_meta.add_argument('--processor-variant', default='default')
    fw_build_meta.add_argument('--processor-model', required=True)
    fw_build_meta.add_argument('--entry-point', default=None)
    fw_build_meta.add_argument('--src', action='append', nargs=2,
                              metavar=('url', 'commit'))
    fw_build_meta.add_argument('--out', required=True)

    # firmware_load_meta
    fw_load_meta = subparsers.add_parser('firmware_load_meta', help='a help')
    fw_load_meta.set_defaults(func=cmd_firmware_load_meta)
    fw_load_meta.add_argument('--processor-id')
    fw_load_meta.add_argument('--processor', required=True)
    fw_load_meta.add_argument('--processor-variant', required=True)
    fw_load_meta.add_argument('--processor-model', default='default')
    fw_load_meta.add_argument('--entry-point', required=True)
    fw_load_meta.add_argument('--load', action='append', nargs=4,
                              metavar=('file', 'file_offset', 'length', 'base_address'))
    fw_load_meta.add_argument('--out', required=True)

    # firmware_all_meta
    fw_all_meta = subparsers.add_parser('firmware_all_meta', help='a help')
    fw_all_meta.set_defaults(func=cmd_firmware_all_meta)
    fw_all_meta.add_argument('--board', required=True)
    fw_all_meta.add_argument('--load-meta-file', action='append', nargs=1)
    fw_all_meta.add_argument('--firmware-build-meta-file', action='append', nargs=1)
    fw_all_meta.add_argument('--out', required=True)

    # parsing
    c_args = parser.parse_args()
    c_args.func(c_args)


if __name__ == '__main__':
    cli_parse()
