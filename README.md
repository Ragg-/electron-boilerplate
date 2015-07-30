# Electron-boilerplate
Electron development environment and foundation feature kit.

## How to use
1. This boilerplate uses `gulp`.
   Please install `node.js(or iojs)` and `gulp` before setup.

2.  Next, clone this repo to your workspace.
    And move cloned workspace.
    ``` shell
    git clone https://github.com/Ragg-/electron-boilerplate.git /path/to/cloning
    cd /path/to/cloning
    ```

3. Install npm modules.
    ``` shell
    npm i
    ```

4. Run gulp, for building codes, on `src/` to `build/`.

5. Run `Hello, world Electron App`? Abort gulp.

6. Change directory to `src/`, and install app's dependent npm modules
   ``` shell
   cd src/
   npm i
   ```

7. Move to workspace root, run gulp, start developing!
   ``` shell
   cd ../
   gulp
   ```

## Develop environment
- For Renderer process code building
    - `Webpack`
    - `Stylus`
    - `CoffeeScript`


- For debugging
    - `electron-connect`


## Builtin feature
### Command flow
- app.command.dispatch("&lt;command name&gt;"[, arguments...])
- app.command.on("&lt;command name&gt;"[, arguments...])

`CommandManager(on Browser, Renderer)` provides Browser&lt;-&gt;Renderer transparent command dispatch.  
CommandManger explode to `global.app.command (on Browser)` or `window.app.command (on Renderer)`.

CommandManger is extends EventEmitter3, if you want handling an command,
call `app.command.on("&lt;command name&gt;", &lt;listener&gt;)` method!

If you want to dispatch the command, call `app.command.dispatch("&lt;command name&gt;"[, arguments...])`.

`command.dispatch` is dispatch command to Browser and Renderer(not other Renderer process).

### Application menu (with scriptable defintion)
_(It's only used on Browser process)_

Application menu definitions in `src/browser/config/menus/{platform}.coffee`  
`TODO: Write this section`

### Multiple window management
`TODO: Write this section`

### CSS Selector based context menu
_(It's only used on Renderer process)_

- app.contextMenu.add("<selector>", <electron's menu template object>)

`TODO: Write this section`
