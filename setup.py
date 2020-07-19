from setuptools import setup


def readme():
    with open('README.rst') as f:
        return f.read()


setup(name='readit',
      version='0.0.1',
      description='Stata Python plugin for reading and appending arbitrary number of files',
      long_description=readme(),
      classifiers=[
          'Development Status :: 2 - Pre-Alpha',
          'Intended Audience :: Developers :: Science/Research :: Education :: End Users/Desktop',
          'License :: MIT License',
          'Programming Language :: Python :: 3',
          'Topic :: Utilities'
      ],
      keywords='IO Stata Data',
      url='https://github.com/wbuchanan/readit',
      author='Billy Buchanan',
      author_email='Billy.Buchanan@fayette.kyschools.us',
      maintainer='Billy Buchanan',
      maintainer_email='Billy.Buchanan@fayette.kyschools.us',
      license='MIT',
      packages=['readit'],
      install_requires=[
          'pandas>=1.0.0',
          'jsonschema',
          'pyarrow',
          'fastparquet>=0.4.0',
          'xlrd',
          'pyreadstat',
          'h5py>=2.10.0',
          'numexpr>=2.7.1',
          'Cython>=0.21',
          'tables>=3.6.1'
      ],
      python_requires = '>=3.6',
      include_package_data=True,
      zip_safe=False)
