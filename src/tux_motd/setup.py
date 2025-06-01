from setuptools import setup

setup(
    name='tux-motd',
    version='0.1',
    py_modules=['tux_motd'],
    entry_points={
        'console_scripts': [
            'tux_motd = tux_motd:main',
        ],
    },
)