#!/usr/bin/env python3
"""Validate a release tag and package the APK with update metadata."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil


def read_version(pubspec=Path('pubspec.yaml')):
    match = re.search(r'^version: (\d+\.\d+\.\d+)\+([1-9]\d*)\s*$',
                      pubspec.read_text(), re.MULTILINE)
    if not match or int(match[2]) > 2100000000:
        raise ValueError('pubspec.yaml must have version: X.Y.Z+BUILD (1..2100000000)')
    return match[1], int(match[2])


def validate_release(tag, version, build_number, previous=None):
    if tag != f'v{version}':
        raise ValueError(f'Tag must match pubspec.yaml: v{version}')
    if previous is not None:
        old_version = previous['version']
        old_build = previous['buildNumber']
        if (not isinstance(old_version, str)
                or not re.fullmatch(r'\d+\.\d+\.\d+', old_version)
                or type(old_build) is not int):
            raise ValueError('Invalid previous release metadata')
        if tuple(map(int, version.split('.'))) <= tuple(map(int, old_version.split('.'))):
            raise ValueError('Version must be greater than the latest release')
        if build_number <= old_build:
            raise ValueError('Build number must be greater than the latest release')


def package_release(apk, output, repository, tag, version, build_number):
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', repository):
        raise ValueError('Repository must be OWNER/NAME')
    output.mkdir(parents=True, exist_ok=True)
    target = output / 'autolog.apk'
    shutil.copyfile(apk, target)
    with target.open('rb') as stream:
        digest = hashlib.file_digest(stream, 'sha256').hexdigest()
    metadata = {
        'version': version,
        'buildNumber': build_number,
        'downloadUrl': f'https://github.com/{repository}/releases/download/{tag}/autolog.apk',
        'sha256': digest,
    }
    (output / 'update.json').write_text(json.dumps(metadata, indent=2) + '\n')
    (output / 'SHA256SUMS').write_text(f'{digest}  autolog.apk\n')
    return metadata


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('tag')
    parser.add_argument('--previous', type=Path)
    parser.add_argument('--apk', type=Path)
    parser.add_argument('--repository', default='kamilb13/autolog')
    parser.add_argument('--output', type=Path, default=Path('build/release'))
    args = parser.parse_args()
    try:
        version, build_number = read_version()
        previous = json.loads(args.previous.read_text()) if args.previous else None
        validate_release(args.tag, version, build_number, previous)
        if args.apk:
            package_release(args.apk, args.output, args.repository, args.tag, version, build_number)
    except (ValueError, KeyError, TypeError, OSError) as error:
        parser.exit(1, f'Release rejected: {error}\n')
    print(f'Validated {version}+{build_number}')


if __name__ == '__main__':
    main()
