# `TestRunner` User Guide
## What is `TestRunner`?
It's a solution for Matlab to batch-run test with multiple variable parameters and execute pre-designated tasks in each run. The library provides API in terms of abstract classes that the user can implement/extend and put in test logics, but the test-runs can be configured entirely in a declarative manner (including tasks and parameters) provided that the logic is well-written. The tasks can be building I/O, data collection, analyzation, data management, and simulations.

The philosophy of this library is that: 
1. If you want to add or remove some component or functionality of a test, you need only to change several values at one place. Compare to using scripts, you then would need to tweak around the logic part (such as a for loop) to scan a parameter and have to take care of the creation/initialization/update/destruction at several places whenever you add a component.
2. With declarative files to configure the tests, you can save them and manage them easily through version management software. 

A set of tests can then run by mainly configuring two declarative files (in YAML):
- `dictschm`: A data file of the parameter dictionaries for the tests. Or a scheme of dictionaries indicating all the possible variations.
- `ioconfig`: An IO configuration file that determines how the multi-test is run, what happens to data collection and analyzation, plottings, video writings, savings, etc. during the test runs. Most entries in the file each corresponds to a component that does a specific job listed above. 

## General Architecture
A test-run consists of two stages. In the first stage an object IO Manager is constructed from the `ioconfig`, containing all information needed for the run, including the task queues. In the second stage the task queues are executed repeatedly, each time with a different set of parameters as desired. 

## When we say ... we mean ...
- the parameter dictionary: A full set of parameter by which a test runs. The dictionary consists purely of key-value pairs, where a key is a string, and a value can be of any type. 
- mono-test: single run of test with a single dictionary.
- multi-test: a collection of tests with varying parameter sets. A test-run is usually the run of a multi-test. The parameters in the multi-test are generated through the `dictschm` file.
- IO Manager: a class that manages all the input/output/actions of a multi-test. Contains components. Its construction is directed by the `ioconfig` file.
- Components: objects that are responsible for data creation, storage, display and on-the-fly analyzation etc..
- Queue Manager: a class that organizes the tasks to be done in each stage of the program. Tasks are grouped in a queue as annotated handles for callbacks functions.
- conversion rules: files that specify how to convert the fields parsed from `ioconfig` and `dictschm` file. For the current version they are YAML files.
- This library: this `TestRunner` library.
- Your project: your project that uses the `TestRunner` library as a subfolder.

## Implement a Runner: An Example
Suppose you want to write a simulation program for a certain dynamic evolution. Your simulation has a space as a playground, usually a grid of points with some fields defined on it, be it density, velocity or some complex amplitude, or a collection of particles, each with a state. You would store the coordinates and the fields in a Matlab's class, the "runner". You would want to setup an initial condition and the environment, and have the target fields evolve by time steps according to your evolution function, which can be properties and methods from the runner. The number of steps are also specified.
#### Inherit the `Iterator`
You can have your class inherit the `Iterator` (an abstract class defined in _this library_), which requires you to implement the function `reset` and `ready` for loading configuration and resetting data, `iter` to evolve, and `wrapup` to conclude the evolution. The `run` function will accumulate the step number until the maximum value or some custom condition is met. The `run` function is inferred so you don't need to define it yourself.

The `Iterator` inherits `DataContainer`, which requires you to specify which custom properties in the runner can be loaded and which parameters can be read through a dictionary automatically. You can also save some properties automatically. The specifications are registered simply by assigning string arrays to `confignames`, `paramsnames` and `datanames`. The loading and exporting functions are implemented automatically so you don't need to write again.

Similarly, there is a `DataObserver` class that's for collecting data and do real-time analysis between steps. This can help capture some finer statistical features while avoid saving too muchd data to process in the end.

Worry not that you forget to implement anything, because Matlab will tell you.

#### Setup register functions
The IO Manager is built through the function `buildmanager`, which prepares components (or rather register such preparation) by the register functions. The register functions can be provided either by _this library_, or specific ones defined in your simulation project. How entries in the `ioconfig` file are bound to the register functions is specified in a table in the `csv` file. A default binding table is already included as `reg_common.csv`, but you can always write extra register functions and bind them to custom IO config registries. The extended binding table can be placed anywhere in _your project_ and pointed to from the `config_run.json` file's `reg_extension` entry.

In the actual `ioconfig` file, the entry for each component follows a format that matches the corresponding register function. I admit this part is less well-defined and what information is needed for each entry may be unclear and difficult to look up to. However, you can always refer to the samples.

#### The declarative files
Many configuration files are required to have the `TestRunner` running, but most are already specified.
##### For project users setting up the project on a new machine, create file
- `config_local.json`: In _your project_. Setup the `testrootdir`, which is where you want to place your test data.
##### Project developer using this library should setup, and users can edit
- `ioconfig_<...>.convrule.yaml`: optionally _your project_. Since `ioconfig` convrules are mostly the same, we mostly use the version in _this library_. Find in `convert/ioconfig.convrule.yaml` Referred to in `config_local.json`.
- `dictschm_<...>.convrule.yaml`: In _your project_. Usually depend on the project's needs. Can refer to `convert/dictschm.convrule.example.yaml`. Referred to in `config_run.json`.
- `reg_<...>.csv`: (Optional) In _your project_. A simple table that tells which register function to use for each block name in `ioconfig`. Including extension functionalities that depend on the project.  
- `reg_common.csv`: In _this library_. A simple table that tells which register function to use for each block name in `ioconfig`. Including only common functionalities. Only edit this if you want to change _this library_ itself other than your own project. You may want to do this if you are not cool with the format from `ioconfig_<...>.yaml` entries.
##### The most commonly edited configurations
- `ioconfig_<...>.yaml`: In _your project_. The YAML file that configures I/O. Referred to in `config_run.json`.
- `dictschm_<...>.yaml`: In _your project_. The YAML file from which variable dictionaries are generated. Referred to in `config_run.json`.
- `config_run.json`: In _your project_. configure the run if you want to use `autorun`. Read by `autorun`. This is helpful when you have multiple `ioconfig_<...>.yaml` files to choose from.
#### Run it with `runfiles`
`runfiles` function runs what is configured in the `ioconfig` file in one call. This function includes the process of setting up IO and queue according the `ioconfig` file through `buildmanagers`, and run the multi-test dictionary `debugdictschm`/`rundebug`/`preptest`. In the end the IO and queue will be assigned in the base workspace.
- arguments
  - `file_config`, file path of the `ioconfig` file.
  - `file_configconv`, file path of the conversion rules for `ioconfig` file.
  - `options`
    - `mode`, mode for the running stage after `buildmanagers`.
      - `debug`, will panic and terminate at whenever exception happens during the running stage. Calls `debugdictschm`. This will make debugging easier since it can pause on the actual error.
      - `normal`, will attempt to clean up in case that exception happens. Calls `rundebug`. This can avail a follow up run of multi-test that completes what's left undone.
      - `testat`. This will only execute the `prep` stage of a mono-test indexed by `fromidx`. Calls `preptest`. Can be used to examine pre-test setup at the specified dictionary without running.
    - `fromidx`, run the multi-test only from a certain index and skip all the mono-tests before that. This can be used for the follow up of an unfinished multi-test.

## Terminologies in these documentations
- Concepts in YAML:
  - key-value pair: a structure in YAML, formatted as `<key> : <value>`. Each value can be either a simple value or a map or a list.
  - map: a structure in YAML of multiple key-value pairs,
    formatted as `{<key> : <value>, <key> : <value>}`
    ```yaml
      key1 : value1
      key2 : value2
    ```   
  - list: a structure in YAML, also known as sequence, formatted as (equivalently) either `[<item>,<item>,<item>]` or
    ```yaml
      - <item>
      - <item>
    ``` 
    where an `<item>` is the same as a `<value>`.
  - section: a key-value pair that's in the root, dividing the entire document.
  - entry: a common key-value pair or an item of a list, usually representing a configuration. 
  - fields: a key-value pair that's toward the leave's side, where the value is something simple like a string or number.
  - Null: `[]`
- Concepts in Matlab:
  - structure: or `struct`, contains fields each with a field name (string) and a value (arbitrary type). Corresponds to the YAML key-value pair.
  - class: like a class in C++. contains properties (like fields) and methods (like functions). Can have inheritance. An abstract class can only be inherited by implementing all abstract properties and methods, not instantiated. For a class `C` with a property `p` and a method `m`, we refer to `p` and `m` as `C::p` or `C::m`, although this is not really Matlab syntax (Accessing through an instance in Matlab is by `.`).
  - array: In an array, every element has to be of the same type. If they are structure, they must have the same field names.
  - cell: contains one element of arbitrary type, All cells are of the same type.
  - cell array: An array of cells, but what is contained in each cell can be of different type even in the same cell array. A YAML list is converted to a cell array.
  - function: functions can have local variables and embedded functions. An embedded function can access the local variables. We refer to an embedded function as `<func_name>/<embedded_func_name>`.
