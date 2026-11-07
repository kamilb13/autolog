import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from release_metadata import package_release, read_version, validate_release


class ReleaseMetadataTests(unittest.TestCase):
    def test_tag_must_match_version(self):
        validate_release('v1.2.3', '1.2.3', 4)
        with self.assertRaises(ValueError):
            validate_release('v1.2.4', '1.2.3', 4)

    def test_both_version_and_build_must_increase(self):
        previous = {'version': '1.2.3', 'buildNumber': 4}
        validate_release('v1.2.4', '1.2.4', 5, previous)
        for version, build in [('1.2.3', 5), ('1.2.2', 6), ('1.2.4', 4), ('1.2.4', 3)]:
            with self.subTest(version=version, build=build), self.assertRaises(ValueError):
                validate_release('v' + version, version, build, previous)

    def test_semantic_versions_are_not_compared_as_strings(self):
        validate_release('v1.10.0', '1.10.0', 11,
                         {'version': '1.9.0', 'buildNumber': 10})

    def test_malformed_previous_release_is_rejected(self):
        for previous in [{'version': '1.0.0', 'buildNumber': True},
                         {'version': 'invalid', 'buildNumber': 1}]:
            with self.assertRaises(ValueError):
                validate_release('v1.1.0', '1.1.0', 2, previous)

    def test_pubspec_requires_a_valid_android_build_number(self):
        with tempfile.TemporaryDirectory() as directory:
            pubspec = Path(directory) / 'pubspec.yaml'
            pubspec.write_text('name: autolog\nversion: 1.2.3+4\n')
            self.assertEqual(read_version(pubspec), ('1.2.3', 4))
            for version in ['1.2.3', '1.2.3+0', '1.2.3+2100000001']:
                pubspec.write_text('version: ' + version + '\n')
                with self.assertRaises(ValueError):
                    read_version(pubspec)

    def test_metadata_matches_the_packaged_apk(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            apk = root / 'input.apk'
            apk.write_bytes(b'APK test fixture')
            output = root / 'release'
            package_release(apk, output, 'kamilb13/autolog', 'v1.2.3', '1.2.3', 4)
            metadata = json.loads((output / 'update.json').read_text())
            digest = hashlib.sha256(apk.read_bytes()).hexdigest()
            self.assertEqual(metadata['buildNumber'], 4)
            self.assertEqual(metadata['sha256'], digest)
            self.assertEqual(metadata['downloadUrl'],
                             'https://github.com/kamilb13/autolog/releases/download/v1.2.3/autolog.apk')
            self.assertEqual((output / 'autolog.apk').read_bytes(), apk.read_bytes())
            self.assertEqual((output / 'SHA256SUMS').read_text(), f'{digest}  autolog.apk\n')
