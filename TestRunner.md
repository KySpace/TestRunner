# `TestRunner`, How it works
This document offers some details of how `TestRunner` works

## `dictschm` Test parameters dictionary scheme files
### Format for a `dictschm` file
The `dictschm` file is a YAML file that contains several sections `Varying`, `Passive` and `Priority`, where in each section the section name is the key while the content serves as a value, so each section is just a huge key-value pair (in the YAML sense) separated by colon. Each section consists of a structure of many key-value pairs. 
```yaml
some_param_name : 5.6
other_param_name : some_param_name * 2
```

The basic parsing from YAML to Matlab is by using a community library https://github.com/MartinKoch123/yaml. The type compatibility between YAML and Matlab is a bit of an issue. In general, the library maintains strings as strings and numbers as double, converts YAML lists to Matlab cell arrays, and key-value pairs into structs with fields.

You can store most dictionary entries in the `Passive` section, meaning that they don't vary in a multi-test. Before the dictionary is used, all the entries are evaluated sequentially from top to bottom. The later entries can be an expression that depends on the previous entries, as well as Matlab functions within the scope (added to the path). This is achieved in the `evalconv` function.

The `Varying` section is declared before `Passive`. Each entry still has the name as key, but a collection of values as the pair's value. The collection can be represented by 
1. a YAML list, which will be converted to cell arrays by the parser we use (So either `[val1, val2, val3]`, or lines starting with `-`). or 
2. a single string of Matlab expression that can be evaluated to cell arrays. This is useful if you want to generate a larger list of values automatically, say, using `linspace` function or even a custom function. The resulting multi-test dictionaries are generated according to the direct product of each varying entry.

Currently, multiple varying entries can exist but each value must be of basic types such as string or numbers and they cannot depend on other varying entries. In `validifyyamlschm`, the entries in `Varying` are attempted to be convert to cells if they are not already. No further evaluation is done.

The `Priority` section allows you to change a variable according to other varying parameter. You can also do this in the `Passive` section, but this will be buried in the deeper part of the code and is hard to keep track of. The `Priority` will allow the entry to be evaluated at the same place as in `Passive`, so that it can still depend on earlier `Passive` entries, but be displayed at the top of th file as something that you intentionally changes compared to the default. You can also assign a number that marks the variation in `Varying` and have multiple variables in `Priority` depending on it, to achieve a direct sum of variations. Together with direct product we can achieve algebraic variation generation!

#### Data flow for generating the dictionaries
```    
    ↓ yaml file 
    loaddictschm ::      
        loadyaml 
        ↓ schm_yaml: with entriy keys of  Varying, Passive
        validifyyamlschm :: make sure that Varying values can be evaluated into cell arrays
    ↓ schm: struct with field Varying Following Fixed
    mkmultidicts :: plan the test order
        fromschm :: make the multidicts accessors
            accessor :: called at each variation of multidicts
                evalconv :: evaluate all the variables in workspace
```

## Queues and Queue Manager
Queues can acts as a event listener. But we can check what are the functions registered and manipulate them.
### Queue units
A `QueueUnit` is just a cell array of function handles, along with a strings array as log. The basic methods facilitates recording the function information when they are added. The `invoke` function can invoke all functions within the queue with arbitrary arguments, but all arguments within the queue are the same.
### Queue Manager
A `QueueManager` contains several `QueueUnit` that could be used during a multi-test. A successfully running multi-test contains three parts: initialization, variations on mono-tests, and finalization.   
The following table shows what arguments are accepted by functions in each `QueueUnit`. a `✓` represent that the argument is acquired from the actual state, otherwise a constant value is fed in (usually because that the value is not well-defined).
```
    ┌ arguments ┐
    io, idx, dict
     ✓  nan        init  ┐
  ┬                      ├ initialize
  │  ✓  nan   ()   link  ┘   
  ↓               
  │  ✓   ✓    ✓    prep  ┐
  │  ✓   ✓    ✓    main  ├ mono-tests 🔁
  │  ✓   ✓    ✓    post  ┘
  ↓                
  ┴  ✓  nan   ()   final - final
                   
     ✓   ✓         panic - panic
```
Except when a panic happens in `normal` mode, then the flow is handled by functions in `panic`. In debug mode, it just exit from where the break happens.
The reason there are `init` and `link` in the initialization stage is that `init` only create objects while `link` links the callbacks to events, some of which can only be done after all objects are created. You can also link the callbacks in `prep` which is what I did before, but then the linked list would grow the more mono-tests are done, which eventually affects performance. Now, `prep` is usually for clearing data or visualization and `post` handles data. We don't want to clear the mono-test data or visualization in `post` because 1. It's cumbersome to make sure that the data is cleared only in the end, and 2. In actual test the people in front of the screen would actually want to appreciate the result from last mono-test when the next mono-test is run, which happens mostly in `main`.
### `ioupdater`
Aside from analysis or output at the end of each mono-test in `post`, you may also want to do so during the `main` stage of the test, such as live update to the plotting window every simulation step. In such a case, you must trigger the update event more flexibly. You can define individual `QueueUnit`s in your class (I've already done it for you in the `Iterator` abstract class) and add callback functions to it. To see how it's done, go to .

## `IOManager`
The IO Manager is a class containing multiple structures containing information of the resources.
- `runner`: What runs the test or simulation.
- `data`: Saves temporary data.
- `visuals`: Holds handles of visual objects, such as windows and plots. 
- `updaters`: Holds function handles triggered by updates.
- `devices`: Intended for peripheral devices or connections, also holds path information.
- `schemeinfo`: Generated from `dictschm`.
- `multidicts`: The accessor to multi-dictionaries.
Along with the Queue Manager, the two managers are built in the `buildmanager` function from the `ioconfig` file. 

## `ioconfig` format and components
The `ioconfig` file, like `dictschm` also contain multiple sections. This time, each one represents either a component type or some option such as `TrialRun`. The format of each components must match how it is interpreted in its corresponding register function. Each component type can contain a list of components, each component is usually an object in the `IOManager` with a unique field name `FieldName`.

## Conversion Rules
The conversion rules are embedded in a separate YAML file. You can find the `testschm`'s conversion rule sample in the _this library_'s path `convert/testschm.convrules.example.yaml`, but you usually need to modify it for _your project_. The `ioconfig`'s conversion rule is `convert/ioconfig.convrule.yaml` by default. In each file, the contents are also divided into several sections.
- `default`: Tells how `mkmultidicts` should evaluate the fields' values (the leaves of the YAML syntax tree) by default. For `dictschm` we want to evaluate most of the strings into numeric values since they may be expressions. Thus I choose it to be `@evalifstring`.
- `overwrite`: However, there may be some variables, or fields (or a field in a cell array of a field) in a struct variable that's intended to be a string. The overwrite can change the default conversion rule at a specific location, in this case, to "doing nothing", or `@id`. The location can be expressed through a path expression which will be matched with every path during evaluation in `evalconv/evalthis`. You can also force the string to be within several options by using `mkescevaluator`, or to escape evaluating `[...]` to cell array by converting back to normal array with `cell2mat`. 
- `pipe`: You can pipe additional conversion operations by adding to the list in `pipe`. One operation that is very important is to convert any `yaml.Null` into `{}` the empty cell. 
Both the `overwrite` and `pipe` section accept a list of entries containing fields of `path` and `funs`. 
#### `path`
In `evalconv/evalthis` which is a function called recursively, a path variable records/build the current position with a string, which in turn is a serialization of the callstack. The `path` in the conversion rule is a regex of some path record. The path record has the following syntax 
- `root`: the root entry of the YAML file.
- `{}`: into the element of a YAML list (a Matlab cell array content).
- `/`: followed by the field name, YAML's key-value access (Matlab field access).
As an example, considering the following snippet.
```yaml
Passive:
    some_var : 
        - {item1 : val1, item2 : val2}
        - {item1 : val3, item2 : val4}
```
the path of every `item1` will be `root/Passive/some_var{}/item1`, but you don't have to match every step exactly.

#### `funs`
Is an expression of a function handle. When this function is applied, there are two arguments: the value and the existing dictionary (as a struct). Most functions wouldn't need the second argument, and you can always use `ignorefrom` to convert it into a function that discard the later arguments.


## Build the Managers from the `ioconfig`
The `ioconfig` file is first raw-processed through the `loadioconfig` function, which already apply the conversion rules. One special rule that I created is for all `ArgsConv` fields, parsed by `parseargs` according to a custom syntax that can greatly shorten the expression. The result is an entry fed into the `buildmanager`. 
### `buildmanager`
The core actions in the `buildmanager` are registers, provided by "register functions" defined in separate files. Some of these register functions are provided in _this library_ for common components, while you can also define custom ones for custom components. But how does `buildmanager` know which register function to use when it's reading the `ioconfig`? It will look up a table that maps the component's type to a register function's name. Matlab will find the right function as long as it is within the search path. All register functions have the same argument signature.
```matlab
reg_something(yaml_entry, io, queue)
```
where the `yaml_entry` is the entry from the `ioconfig` file under the right component type (not the component name which can be customly specified). In other words, it is the value of the key coincident with the component type. The YAML format requires that the key must be unique within the same file on the same hierarchy.
The register map table is recorded in a `csv` file. The map also depends on an extra value from the key `TrialRun`. When set, data saving is expected to be disabled. 
### The register functions
Naively, you may think the register function creates the corresponding objects/components used in the test, as well as putting future tasks such as updates or destructions somewhere in the `QueueManager` using the method `QueueManager::register`. But there are benefits to also postpone the initization of objects to `init` as well.
These callback functions are defined as nested functions within the register function, able to capture the local variables. These functions can assign or access the relevant object in the `io` by it's name (which is usually specified in `ioconfig`) and the function `evalinio`. Therefore, you can refer to these objects in the `ioconfig` fields.







  