# Compressed Big Brother FileSystem (CBBFS)

The Compressed Big Brother FileSystem (CBBFS) is a userspace filesystem implemented using the FUSE (Filesystem in UserSpace) framework and aims to provide 2 distinct functionalities:

1. Logging any filesystem operation that happens in the cbbfs to a log file
2. Compressing files by storing them internaly as a sequence of data blocks

The CBBFS has been implemented using the BBFS (Big Brother FileSystem) as a template which provides the logging part of CBBFS's functionality.

## Features

- **Non-Volatile Storage** :

  CBBFS ensures data persistence across system reboots or power cycles, maintaining stored data integrity over time

- **Variable Offset Reads and Writes** :

  Ability to read from or write to files at any offset, allowing for flexible data manipulation within files

- **Variable Length Reads and Writes** :

  Support for reading from or writing to files of varying sizes, accommodating dynamic data storage requirements

- **Variable File Size Support** :

  CBBFS is capable of handling files of any size, without limitations on maximum file size

- **Filesystem Metadata & Directory Support** :

  Support of filesystem metadata such as file names, sizes, permissions, and directory structures


## Implementation Details

CBBFS can be broken down to multiple core data structures, operations and design decisions, specifically :

- Inside the rootdir of CBBFS there is a hidden directory (.cbbfsstorage/) which is used as the storage directory for all data blocks, non accesible within mountdir

- Every data block consists of 4096 bytes (easily modifiable in source code) and is named after its SHA1 hash in hexadecimal form (40 bytes total).

- Data blocks in main memory are represented by struct _blk_ which is a doubly linked list node and stores the hash value and the usage counter of a single block. This structure does not contain the actual block's data and occupies a total of 40 bytes.

- Every file is represented in rootdir as a sequence of hashes of their corresponding data blocks.
  Reads and writes are responsible for translating these sequences and fetching/writing the requested data.

- When writing blocks into a file we check if the block already exists by searching for its hash in the _blk_ list. If the hash exists we increase the counter, else we create the block and store its _blk_ structure in the _blk_ list.

- If any file has suffix which acquires disk space less than a block then this suffix is stored in the rootdir/.cbbfsstorage/path/of/file and the character L is placed at the end of the file's hash sequence.

- The read as well as the writing operation first resolves the given offset and then reads the requested bytes.

- The read operation makes sure to not read more than the file's available data.

- The getattr operation translates the size of the file which contains its sequence of hashes to its actual size.

- The unlink operation, after reading all the hashes that constitute the file, decrements the count of each corresponding data block, and then deletes the file. If a block count reaches 0 (no longer in use), the corresponding data block file is deleted from the storage and removed from the list.

## Usage

For ease of use there is a Makefile containg all the necessary fuctionalities for compiling, mounting, testing and unmounting cbbfs. Specifically the available operations are :

- **Compile**: make compile
- **Mount**: make mount
- **Test**: make tests
- **Unmount**: make unmount
- **Clean**: make clean
