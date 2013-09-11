from setuptools import setup

setup(
    name='dataware-catalog',
    version='0.1',
    packages=['dataware', 'dataware.catalog'],
    scripts=['dataware-catalog'],
    license='MIT license',
    long_description=open('README.txt').read(),
    include_package_data=True,
)
