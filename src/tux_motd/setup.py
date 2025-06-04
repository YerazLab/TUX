from setuptools import setup

setup(
    name='tux-motd',
    py_modules=['tux_motd'],
    entry_points={
        'console_scripts': [
            'tux_motd = tux_motd:main',
        ],
    },
)