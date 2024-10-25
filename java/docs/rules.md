<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Java rules


## Rules

- [java_binary](#java_binary)
- [java_import](#java_import)
- [java_library](#java_library)
- [java_package_configuration](#java_package_configuration)
- [java_plugin](#java_plugin)
- [java_runtime](#java_runtime)
- [java_test](#java_test)
- [java_toolchain](#java_toolchain)


<a id="java_binary"></a>

## java_binary

<pre>
java_binary(<a href="#java_binary-name">name</a>, <a href="#java_binary-deps">deps</a>, <a href="#java_binary-srcs">srcs</a>, <a href="#java_binary-data">data</a>, <a href="#java_binary-resources">resources</a>, <a href="#java_binary-add_exports">add_exports</a>, <a href="#java_binary-add_opens">add_opens</a>, <a href="#java_binary-bootclasspath">bootclasspath</a>,
            <a href="#java_binary-classpath_resources">classpath_resources</a>, <a href="#java_binary-create_executable">create_executable</a>, <a href="#java_binary-deploy_env">deploy_env</a>, <a href="#java_binary-deploy_manifest_lines">deploy_manifest_lines</a>, <a href="#java_binary-env">env</a>, <a href="#java_binary-javacopts">javacopts</a>,
            <a href="#java_binary-jvm_flags">jvm_flags</a>, <a href="#java_binary-launcher">launcher</a>, <a href="#java_binary-licenses">licenses</a>, <a href="#java_binary-main_class">main_class</a>, <a href="#java_binary-neverlink">neverlink</a>, <a href="#java_binary-plugins">plugins</a>, <a href="#java_binary-resource_strip_prefix">resource_strip_prefix</a>,
            <a href="#java_binary-runtime_deps">runtime_deps</a>, <a href="#java_binary-stamp">stamp</a>, <a href="#java_binary-use_launcher">use_launcher</a>, <a href="#java_binary-use_testrunner">use_testrunner</a>)
</pre>

<p>
  Builds a Java archive ("jar file"), plus a wrapper shell script with the same name as the rule.
  The wrapper shell script uses a classpath that includes, among other things, a jar file for each
  library on which the binary depends. When running the wrapper shell script, any nonempty
  <code>JAVABIN</code> environment variable will take precedence over the version specified via
  Bazel's <code>--java_runtime_version</code> flag.
</p>
<p>
  The wrapper script accepts several unique flags. Refer to
  <code>//src/main/java/com/google/devtools/build/lib/bazel/rules/java/java_stub_template.txt</code>
  for a list of configurable flags and environment variables accepted by the wrapper.
</p>

<h4 id="java_binary_implicit_outputs">Implicit output targets</h4>
<ul>
  <li><code><var>name</var>.jar</code>: A Java archive, containing the class files and other
    resources corresponding to the binary's direct dependencies.</li>
  <li><code><var>name</var>-src.jar</code>: An archive containing the sources ("source
    jar").</li>
  <li><code><var>name</var>_deploy.jar</code>: A Java archive suitable for deployment (only
    built if explicitly requested).
    <p>
      Building the <code>&lt;<var>name</var>&gt;_deploy.jar</code> target for your rule
      creates a self-contained jar file with a manifest that allows it to be run with the
      <code>java -jar</code> command or with the wrapper script's <code>--singlejar</code>
      option. Using the wrapper script is preferred to <code>java -jar</code> because it
      also passes the <a href="#java_binary-jvm_flags">JVM flags</a> and the options
      to load native libraries.
    </p>
    <p>
      The deploy jar contains all the classes that would be found by a classloader that
      searched the classpath from the binary's wrapper script from beginning to end. It also
      contains the native libraries needed for dependencies. These are automatically loaded
      into the JVM at runtime.
    </p>
    <p>If your target specifies a <a href="#java_binary.launcher">launcher</a>
      attribute, then instead of being a normal JAR file, the _deploy.jar will be a
      native binary. This will contain the launcher plus any native (C++) dependencies of
      your rule, all linked into a static binary. The actual jar file's bytes will be
      appended to that native binary, creating a single binary blob containing both the
      executable and the Java code. You can execute the resulting jar file directly
      like you would execute any native binary.</p>
  </li>
  <li><code><var>name</var>_deploy-src.jar</code>: An archive containing the sources
    collected from the transitive closure of the target. These will match the classes in the
    <code>deploy.jar</code> except where jars have no matching source jar.</li>
</ul>

<p>
It is good practice to use the name of the source file that is the main entry point of the
application (minus the extension). For example, if your entry point is called
<code>Main.java</code>, then your name could be <code>Main</code>.
</p>

<p>
  A <code>deps</code> attribute is not allowed in a <code>java_binary</code> rule without
  <a href="#java_binary-srcs"><code>srcs</code></a>; such a rule requires a
  <a href="#java_binary-main_class"><code>main_class</code></a> provided by
  <a href="#java_binary-runtime_deps"><code>runtime_deps</code></a>.
</p>

<p>The following code snippet illustrates a common mistake:</p>

<pre class="code">
<code class="lang-starlark">
java_binary(
    name = "DontDoThis",
    srcs = [
        <var>...</var>,
        <code class="deprecated">"GeneratedJavaFile.java"</code>,  # a generated .java file
    ],
    deps = [<code class="deprecated">":generating_rule",</code>],  # rule that generates that file
)
</code>
</pre>

<p>Do this instead:</p>

<pre class="code">
<code class="lang-starlark">
java_binary(
    name = "DoThisInstead",
    srcs = [
        <var>...</var>,
        ":generating_rule",
    ],
)
</code>
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_binary-deps"></a>deps |  The list of other libraries to be linked in to the target. See general comments about <code>deps</code> at <a href="common-definitions.html#typical-attributes">Typical attributes defined by most build rules</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-srcs"></a>srcs |  The list of source files that are processed to create the target. This attribute is almost always required; see exceptions below. <p> Source files of type <code>.java</code> are compiled. In case of generated <code>.java</code> files it is generally advisable to put the generating rule's name here instead of the name of the file itself. This not only improves readability but makes the rule more resilient to future changes: if the generating rule generates different files in the future, you only need to fix one place: the <code>outs</code> of the generating rule. You should not list the generating rule in <code>deps</code> because it is a no-op. </p> <p> Source files of type <code>.srcjar</code> are unpacked and compiled. (This is useful if you need to generate a set of <code>.java</code> files with a genrule.) </p> <p> Rules: if the rule (typically <code>genrule</code> or <code>filegroup</code>) generates any of the files listed above, they will be used the same way as described for source files. </p><br><br><p> This argument is almost always required, except if a <a href="#java_binary.main_class"><code>main_class</code></a> attribute specifies a class on the runtime classpath or you specify the <code>runtime_deps</code> argument. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-data"></a>data |  The list of files needed by this library at runtime. See general comments about <code>data</code> at <a href="${link common-definitions#typical-attributes}">Typical attributes defined by most build rules</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-resources"></a>resources |  A list of data files to include in a Java jar.<br><br><p> Resources may be source files or generated files. </p><br><br><p> If resources are specified, they will be bundled in the jar along with the usual <code>.class</code> files produced by compilation. The location of the resources inside of the jar file is determined by the project structure. Bazel first looks for Maven's <a href="https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html">standard directory layout</a>, (a "src" directory followed by a "resources" directory grandchild). If that is not found, Bazel then looks for the topmost directory named "java" or "javatests" (so, for example, if a resource is at <code>&lt;workspace root&gt;/x/java/y/java/z</code>, the path of the resource will be <code>y/java/z</code>. This heuristic cannot be overridden, however, the <code>resource_strip_prefix</code> attribute can be used to specify a specific alternative directory for resource files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-add_exports"></a>add_exports |  Allow this library to access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-exports= flags.   | List of strings | optional |  `[]`  |
| <a id="java_binary-add_opens"></a>add_opens |  Allow this library to reflectively access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-opens= flags.   | List of strings | optional |  `[]`  |
| <a id="java_binary-bootclasspath"></a>bootclasspath |  Restricted API, do not use!   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_binary-classpath_resources"></a>classpath_resources |  <em class="harmful">DO NOT USE THIS OPTION UNLESS THERE IS NO OTHER WAY)</em> <p> A list of resources that must be located at the root of the java tree. This attribute's only purpose is to support third-party libraries that require that their resources be found on the classpath as exactly <code>"myconfig.xml"</code>. It is only allowed on binaries and not libraries, due to the danger of namespace conflicts. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-create_executable"></a>create_executable |  Deprecated, use <code>java_single_jar</code> instead.   | Boolean | optional |  `True`  |
| <a id="java_binary-deploy_env"></a>deploy_env |  A list of other <code>java_binary</code> targets which represent the deployment environment for this binary. Set this attribute when building a plugin which will be loaded by another <code>java_binary</code>.<br/> Setting this attribute excludes all dependencies from the runtime classpath (and the deploy jar) of this binary that are shared between this binary and the targets specified in <code>deploy_env</code>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-deploy_manifest_lines"></a>deploy_manifest_lines |  A list of lines to add to the <code>META-INF/manifest.mf</code> file generated for the <code>*_deploy.jar</code> target. The contents of this attribute are <em>not</em> subject to <a href="make-variables.html">"Make variable"</a> substitution.   | List of strings | optional |  `[]`  |
| <a id="java_binary-env"></a>env |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="java_binary-javacopts"></a>javacopts |  Extra compiler options for this binary. Subject to <a href="make-variables.html">"Make variable"</a> substitution and <a href="common-definitions.html#sh-tokenization">Bourne shell tokenization</a>. <p>These compiler options are passed to javac after the global compiler options.</p>   | List of strings | optional |  `[]`  |
| <a id="java_binary-jvm_flags"></a>jvm_flags |  A list of flags to embed in the wrapper script generated for running this binary. Subject to <a href="${link make-variables#location}">$(location)</a> and <a href="make-variables.html">"Make variable"</a> substitution, and <a href="common-definitions.html#sh-tokenization">Bourne shell tokenization</a>.<br><br><p>The wrapper script for a Java binary includes a CLASSPATH definition (to find all the dependent jars) and invokes the right Java interpreter. The command line generated by the wrapper script includes the name of the main class followed by a <code>"$@"</code> so you can pass along other arguments after the classname.  However, arguments intended for parsing by the JVM must be specified <i>before</i> the classname on the command line.  The contents of <code>jvm_flags</code> are added to the wrapper script before the classname is listed.</p><br><br><p>Note that this attribute has <em>no effect</em> on <code>*_deploy.jar</code> outputs.</p>   | List of strings | optional |  `[]`  |
| <a id="java_binary-launcher"></a>launcher |  Specify a binary that will be used to run your Java program instead of the normal <code>bin/java</code> program included with the JDK. The target must be a <code>cc_binary</code>. Any <code>cc_binary</code> that implements the <a href="http://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/invocation.html"> Java Invocation API</a> can be specified as a value for this attribute.<br><br><p>By default, Bazel will use the normal JDK launcher (bin/java or java.exe).</p><br><br><p>The related <a href="${link user-manual#flag--java_launcher}"><code> --java_launcher</code></a> Bazel flag affects only those <code>java_binary</code> and <code>java_test</code> targets that have <i>not</i> specified a <code>launcher</code> attribute.</p><br><br><p>Note that your native (C++, SWIG, JNI) dependencies will be built differently depending on whether you are using the JDK launcher or another launcher:</p><br><br><ul> <li>If you are using the normal JDK launcher (the default), native dependencies are built as a shared library named <code>{name}_nativedeps.so</code>, where <code>{name}</code> is the <code>name</code> attribute of this java_binary rule. Unused code is <em>not</em> removed by the linker in this configuration.</li><br><br><li>If you are using any other launcher, native (C++) dependencies are statically linked into a binary named <code>{name}_nativedeps</code>, where <code>{name}</code> is the <code>name</code> attribute of this java_binary rule. In this case, the linker will remove any code it thinks is unused from the resulting binary, which means any C++ code accessed only via JNI may not be linked in unless that <code>cc_library</code> target specifies <code>alwayslink = True</code>.</li> </ul><br><br><p>When using any launcher other than the default JDK launcher, the format of the <code>*_deploy.jar</code> output changes. See the main <a href="#java_binary">java_binary</a> docs for details.</p>   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_binary-licenses"></a>licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_binary-main_class"></a>main_class |  Name of class with <code>main()</code> method to use as entry point. If a rule uses this option, it does not need a <code>srcs=[...]</code> list. Thus, with this attribute one can make an executable from a Java library that already contains one or more <code>main()</code> methods. <p> The value of this attribute is a class name, not a source file. The class must be available at runtime: it may be compiled by this rule (from <code>srcs</code>) or provided by direct or transitive dependencies (through <code>runtime_deps</code> or <code>deps</code>). If the class is unavailable, the binary will fail at runtime; there is no build-time check. </p>   | String | optional |  `""`  |
| <a id="java_binary-neverlink"></a>neverlink |  -   | Boolean | optional |  `False`  |
| <a id="java_binary-plugins"></a>plugins |  Java compiler plugins to run at compile-time. Every <code>java_plugin</code> specified in this attribute will be run whenever this rule is built. A library may also inherit plugins from dependencies that use <code><a href="#java_library.exported_plugins">exported_plugins</a></code>. Resources generated by the plugin will be included in the resulting jar of this rule.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-resource_strip_prefix"></a>resource_strip_prefix |  The path prefix to strip from Java resources. <p> If specified, this path prefix is stripped from every file in the <code>resources</code> attribute. It is an error for a resource file not to be under this directory. If not specified (the default), the path of resource file is determined according to the same logic as the Java package of source files. For example, a source file at <code>stuff/java/foo/bar/a.txt</code> will be located at <code>foo/bar/a.txt</code>. </p>   | String | optional |  `""`  |
| <a id="java_binary-runtime_deps"></a>runtime_deps |  Libraries to make available to the final binary or test at runtime only. Like ordinary <code>deps</code>, these will appear on the runtime classpath, but unlike them, not on the compile-time classpath. Dependencies needed only at runtime should be listed here. Dependency-analysis tools should ignore targets that appear in both <code>runtime_deps</code> and <code>deps</code>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_binary-stamp"></a>stamp |  Whether to encode build information into the binary. Possible values: <ul> <li>   <code>stamp = 1</code>: Always stamp the build information into the binary, even in   <a href="${link user-manual#flag--stamp}"><code>--nostamp</code></a> builds. <b>This   setting should be avoided</b>, since it potentially kills remote caching for the   binary and any downstream actions that depend on it. </li> <li>   <code>stamp = 0</code>: Always replace build information by constant values. This   gives good build result caching. </li> <li>   <code>stamp = -1</code>: Embedding of build information is controlled by the   <a href="${link user-manual#flag--stamp}"><code>--[no]stamp</code></a> flag. </li> </ul> <p>Stamped binaries are <em>not</em> rebuilt unless their dependencies change.</p>   | Integer | optional |  `-1`  |
| <a id="java_binary-use_launcher"></a>use_launcher |  Whether the binary should use a custom launcher.<br><br><p>If this attribute is set to false, the <a href="${link java_binary.launcher}">launcher</a> attribute  and the related <a href="${link user-manual#flag--java_launcher}"><code>--java_launcher</code></a> flag will be ignored for this target.   | Boolean | optional |  `True`  |
| <a id="java_binary-use_testrunner"></a>use_testrunner |  Use the test runner (by default <code>com.google.testing.junit.runner.BazelTestRunner</code>) class as the main entry point for a Java program, and provide the test class to the test runner as a value of <code>bazel.test_suite</code> system property.<br><br><br/> You can use this to override the default behavior, which is to use test runner for <code>java_test</code> rules, and not use it for <code>java_binary</code> rules.  It is unlikely you will want to do this.  One use is for <code>AllTest</code> rules that are invoked by another rule (to set up a database before running the tests, for example).  The <code>AllTest</code> rule must be declared as a <code>java_binary</code>, but should still use the test runner as its main entry point.<br><br>The name of a test runner class can be overridden with <code>main_class</code> attribute.   | Boolean | optional |  `False`  |


<a id="java_import"></a>

## java_import

<pre>
java_import(<a href="#java_import-name">name</a>, <a href="#java_import-deps">deps</a>, <a href="#java_import-data">data</a>, <a href="#java_import-add_exports">add_exports</a>, <a href="#java_import-add_opens">add_opens</a>, <a href="#java_import-constraints">constraints</a>, <a href="#java_import-exports">exports</a>, <a href="#java_import-jars">jars</a>, <a href="#java_import-licenses">licenses</a>,
            <a href="#java_import-neverlink">neverlink</a>, <a href="#java_import-proguard_specs">proguard_specs</a>, <a href="#java_import-runtime_deps">runtime_deps</a>, <a href="#java_import-srcjar">srcjar</a>)
</pre>

<p>
  This rule allows the use of precompiled <code>.jar</code> files as
  libraries for <code><a href="#java_library">java_library</a></code> and
  <code>java_binary</code> rules.
</p>

<h4 id="java_import_examples">Examples</h4>

<pre class="code">
<code class="lang-starlark">
    java_import(
        name = "maven_model",
        jars = [
            "maven_model/maven-aether-provider-3.2.3.jar",
            "maven_model/maven-model-3.2.3.jar",
            "maven_model/maven-model-builder-3.2.3.jar",
        ],
    )
</code>
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_import-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_import-deps"></a>deps |  The list of other libraries to be linked in to the target. See <a href="${link java_library.deps}">java_library.deps</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_import-data"></a>data |  The list of files needed by this rule at runtime.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_import-add_exports"></a>add_exports |  Allow this library to access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-exports= flags.   | List of strings | optional |  `[]`  |
| <a id="java_import-add_opens"></a>add_opens |  Allow this library to reflectively access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-opens= flags.   | List of strings | optional |  `[]`  |
| <a id="java_import-constraints"></a>constraints |  Extra constraints imposed on this rule as a Java library.   | List of strings | optional |  `[]`  |
| <a id="java_import-exports"></a>exports |  Targets to make available to users of this rule. See <a href="${link java_library.exports}">java_library.exports</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_import-jars"></a>jars |  The list of JAR files provided to Java targets that depend on this target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="java_import-licenses"></a>licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_import-neverlink"></a>neverlink |  Only use this library for compilation and not at runtime. Useful if the library will be provided by the runtime environment during execution. Examples of libraries like this are IDE APIs for IDE plug-ins or <code>tools.jar</code> for anything running on a standard JDK.   | Boolean | optional |  `False`  |
| <a id="java_import-proguard_specs"></a>proguard_specs |  Files to be used as Proguard specification. These will describe the set of specifications to be used by Proguard. If specified, they will be added to any <code>android_binary</code> target depending on this library.<br><br>The files included here must only have idempotent rules, namely -dontnote, -dontwarn, assumenosideeffects, and rules that start with -keep. Other options can only appear in <code>android_binary</code>'s proguard_specs, to ensure non-tautological merges.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_import-runtime_deps"></a>runtime_deps |  Libraries to make available to the final binary or test at runtime only. See <a href="${link java_library.runtime_deps}">java_library.runtime_deps</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_import-srcjar"></a>srcjar |  A JAR file that contains source code for the compiled JAR files.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="java_library"></a>

## java_library

<pre>
java_library(<a href="#java_library-name">name</a>, <a href="#java_library-deps">deps</a>, <a href="#java_library-srcs">srcs</a>, <a href="#java_library-data">data</a>, <a href="#java_library-resources">resources</a>, <a href="#java_library-add_exports">add_exports</a>, <a href="#java_library-add_opens">add_opens</a>, <a href="#java_library-bootclasspath">bootclasspath</a>,
             <a href="#java_library-exported_plugins">exported_plugins</a>, <a href="#java_library-exports">exports</a>, <a href="#java_library-javabuilder_jvm_flags">javabuilder_jvm_flags</a>, <a href="#java_library-javacopts">javacopts</a>, <a href="#java_library-licenses">licenses</a>, <a href="#java_library-neverlink">neverlink</a>,
             <a href="#java_library-plugins">plugins</a>, <a href="#java_library-proguard_specs">proguard_specs</a>, <a href="#java_library-resource_strip_prefix">resource_strip_prefix</a>, <a href="#java_library-runtime_deps">runtime_deps</a>)
</pre>

<p>This rule compiles and links sources into a <code>.jar</code> file.</p>

<h4>Implicit outputs</h4>
<ul>
  <li><code>lib<var>name</var>.jar</code>: A Java archive containing the class files.</li>
  <li><code>lib<var>name</var>-src.jar</code>: An archive containing the sources ("source
    jar").</li>
</ul>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_library-deps"></a>deps |  The list of libraries to link into this library. See general comments about <code>deps</code> at <a href="${link common-definitions#typical-attributes}">Typical attributes defined by most build rules</a>. <p>   The jars built by <code>java_library</code> rules listed in <code>deps</code> will be on   the compile-time classpath of this rule. Furthermore the transitive closure of their   <code>deps</code>, <code>runtime_deps</code> and <code>exports</code> will be on the   runtime classpath. </p> <p>   By contrast, targets in the <code>data</code> attribute are included in the runfiles but   on neither the compile-time nor runtime classpath. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-srcs"></a>srcs |  The list of source files that are processed to create the target. This attribute is almost always required; see exceptions below. <p> Source files of type <code>.java</code> are compiled. In case of generated <code>.java</code> files it is generally advisable to put the generating rule's name here instead of the name of the file itself. This not only improves readability but makes the rule more resilient to future changes: if the generating rule generates different files in the future, you only need to fix one place: the <code>outs</code> of the generating rule. You should not list the generating rule in <code>deps</code> because it is a no-op. </p> <p> Source files of type <code>.srcjar</code> are unpacked and compiled. (This is useful if you need to generate a set of <code>.java</code> files with a genrule.) </p> <p> Rules: if the rule (typically <code>genrule</code> or <code>filegroup</code>) generates any of the files listed above, they will be used the same way as described for source files. </p> <p> Source files of type <code>.properties</code> are treated as resources. </p><br><br><p>All other files are ignored, as long as there is at least one file of a file type described above. Otherwise an error is raised.</p><br><br><p> This argument is almost always required, except if you specify the <code>runtime_deps</code> argument. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-data"></a>data |  The list of files needed by this library at runtime. See general comments about <code>data</code> at <a href="${link common-definitions#typical-attributes}">Typical attributes defined by most build rules</a>. <p>   When building a <code>java_library</code>, Bazel doesn't put these files anywhere; if the   <code>data</code> files are generated files then Bazel generates them. When building a   test that depends on this <code>java_library</code> Bazel copies or links the   <code>data</code> files into the runfiles area. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-resources"></a>resources |  A list of data files to include in a Java jar. <p> Resources may be source files or generated files. </p><br><br><p> If resources are specified, they will be bundled in the jar along with the usual <code>.class</code> files produced by compilation. The location of the resources inside of the jar file is determined by the project structure. Bazel first looks for Maven's <a href="https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html">standard directory layout</a>, (a "src" directory followed by a "resources" directory grandchild). If that is not found, Bazel then looks for the topmost directory named "java" or "javatests" (so, for example, if a resource is at <code>&lt;workspace root&gt;/x/java/y/java/z</code>, the path of the resource will be <code>y/java/z</code>. This heuristic cannot be overridden, however, the <code>resource_strip_prefix</code> attribute can be used to specify a specific alternative directory for resource files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-add_exports"></a>add_exports |  Allow this library to access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-exports= flags.   | List of strings | optional |  `[]`  |
| <a id="java_library-add_opens"></a>add_opens |  Allow this library to reflectively access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-opens= flags.   | List of strings | optional |  `[]`  |
| <a id="java_library-bootclasspath"></a>bootclasspath |  Restricted API, do not use!   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_library-exported_plugins"></a>exported_plugins |  The list of <code><a href="#${link java_plugin}">java_plugin</a></code>s (e.g. annotation processors) to export to libraries that directly depend on this library. <p>   The specified list of <code>java_plugin</code>s will be applied to any library which   directly depends on this library, just as if that library had explicitly declared these   labels in <code><a href="${link java_library.plugins}">plugins</a></code>. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-exports"></a>exports |  Exported libraries. <p>   Listing rules here will make them available to parent rules, as if the parents explicitly   depended on these rules. This is not true for regular (non-exported) <code>deps</code>. </p> <p>   Summary: a rule <i>X</i> can access the code in <i>Y</i> if there exists a dependency   path between them that begins with a <code>deps</code> edge followed by zero or more   <code>exports</code> edges. Let's see some examples to illustrate this. </p> <p>   Assume <i>A</i> depends on <i>B</i> and <i>B</i> depends on <i>C</i>. In this case   C is a <em>transitive</em> dependency of A, so changing C's sources and rebuilding A will   correctly rebuild everything. However A will not be able to use classes in C. To allow   that, either A has to declare C in its <code>deps</code>, or B can make it easier for A   (and anything that may depend on A) by declaring C in its (B's) <code>exports</code>   attribute. </p> <p>   The closure of exported libraries is available to all direct parent rules. Take a slightly   different example: A depends on B, B depends on C and D, and also exports C but not D.   Now A has access to C but not to D. Now, if C and D exported some libraries, C' and D'   respectively, A could only access C' but not D'. </p> <p>   Important: an exported rule is not a regular dependency. Sticking to the previous example,   if B exports C and wants to also use C, it has to also list it in its own   <code>deps</code>. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-javabuilder_jvm_flags"></a>javabuilder_jvm_flags |  Restricted API, do not use!   | List of strings | optional |  `[]`  |
| <a id="java_library-javacopts"></a>javacopts |  Extra compiler options for this library. Subject to <a href="make-variables.html">"Make variable"</a> substitution and <a href="common-definitions.html#sh-tokenization">Bourne shell tokenization</a>. <p>These compiler options are passed to javac after the global compiler options.</p>   | List of strings | optional |  `[]`  |
| <a id="java_library-licenses"></a>licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_library-neverlink"></a>neverlink |  Whether this library should only be used for compilation and not at runtime. Useful if the library will be provided by the runtime environment during execution. Examples of such libraries are the IDE APIs for IDE plug-ins or <code>tools.jar</code> for anything running on a standard JDK. <p>   Note that <code>neverlink = True</code> does not prevent the compiler from inlining material   from this library into compilation targets that depend on it, as permitted by the Java   Language Specification (e.g., <code>static final</code> constants of <code>String</code>   or of primitive types). The preferred use case is therefore when the runtime library is   identical to the compilation library. </p> <p>   If the runtime library differs from the compilation library then you must ensure that it   differs only in places that the JLS forbids compilers to inline (and that must hold for   all future versions of the JLS). </p>   | Boolean | optional |  `False`  |
| <a id="java_library-plugins"></a>plugins |  Java compiler plugins to run at compile-time. Every <code>java_plugin</code> specified in this attribute will be run whenever this rule is built. A library may also inherit plugins from dependencies that use <code><a href="#java_library.exported_plugins">exported_plugins</a></code>. Resources generated by the plugin will be included in the resulting jar of this rule.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-proguard_specs"></a>proguard_specs |  Files to be used as Proguard specification. These will describe the set of specifications to be used by Proguard. If specified, they will be added to any <code>android_binary</code> target depending on this library.<br><br>The files included here must only have idempotent rules, namely -dontnote, -dontwarn, assumenosideeffects, and rules that start with -keep. Other options can only appear in <code>android_binary</code>'s proguard_specs, to ensure non-tautological merges.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_library-resource_strip_prefix"></a>resource_strip_prefix |  The path prefix to strip from Java resources. <p> If specified, this path prefix is stripped from every file in the <code>resources</code> attribute. It is an error for a resource file not to be under this directory. If not specified (the default), the path of resource file is determined according to the same logic as the Java package of source files. For example, a source file at <code>stuff/java/foo/bar/a.txt</code> will be located at <code>foo/bar/a.txt</code>. </p>   | String | optional |  `""`  |
| <a id="java_library-runtime_deps"></a>runtime_deps |  Libraries to make available to the final binary or test at runtime only. Like ordinary <code>deps</code>, these will appear on the runtime classpath, but unlike them, not on the compile-time classpath. Dependencies needed only at runtime should be listed here. Dependency-analysis tools should ignore targets that appear in both <code>runtime_deps</code> and <code>deps</code>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="java_package_configuration"></a>

## java_package_configuration

<pre>
java_package_configuration(<a href="#java_package_configuration-name">name</a>, <a href="#java_package_configuration-data">data</a>, <a href="#java_package_configuration-javacopts">javacopts</a>, <a href="#java_package_configuration-output_licenses">output_licenses</a>, <a href="#java_package_configuration-packages">packages</a>, <a href="#java_package_configuration-system">system</a>)
</pre>

<p>
Configuration to apply to a set of packages.
Configurations can be added to
<code><a href="${link java_toolchain.javacopts}">java_toolchain.javacopts</a></code>s.
</p>

<h4 id="java_package_configuration_example">Example:</h4>

<pre class="code">
<code class="lang-starlark">

java_package_configuration(
    name = "my_configuration",
    packages = [":my_packages"],
    javacopts = ["-Werror"],
)

package_group(
    name = "my_packages",
    packages = [
        "//com/my/project/...",
        "-//com/my/project/testing/...",
    ],
)

java_toolchain(
    ...,
    package_configuration = [
        ":my_configuration",
    ]
)

</code>
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_package_configuration-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_package_configuration-data"></a>data |  The list of files needed by this configuration at runtime.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_package_configuration-javacopts"></a>javacopts |  Java compiler flags.   | List of strings | optional |  `[]`  |
| <a id="java_package_configuration-output_licenses"></a>output_licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_package_configuration-packages"></a>packages |  The set of <code><a href="${link package_group}">package_group</a></code>s the configuration should be applied to.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_package_configuration-system"></a>system |  Corresponds to javac's --system flag.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="java_plugin"></a>

## java_plugin

<pre>
java_plugin(<a href="#java_plugin-name">name</a>, <a href="#java_plugin-deps">deps</a>, <a href="#java_plugin-srcs">srcs</a>, <a href="#java_plugin-data">data</a>, <a href="#java_plugin-resources">resources</a>, <a href="#java_plugin-add_exports">add_exports</a>, <a href="#java_plugin-add_opens">add_opens</a>, <a href="#java_plugin-bootclasspath">bootclasspath</a>, <a href="#java_plugin-generates_api">generates_api</a>,
            <a href="#java_plugin-javabuilder_jvm_flags">javabuilder_jvm_flags</a>, <a href="#java_plugin-javacopts">javacopts</a>, <a href="#java_plugin-licenses">licenses</a>, <a href="#java_plugin-neverlink">neverlink</a>, <a href="#java_plugin-output_licenses">output_licenses</a>, <a href="#java_plugin-plugins">plugins</a>,
            <a href="#java_plugin-processor_class">processor_class</a>, <a href="#java_plugin-proguard_specs">proguard_specs</a>, <a href="#java_plugin-resource_strip_prefix">resource_strip_prefix</a>)
</pre>

<p>
  <code>java_plugin</code> defines plugins for the Java compiler run by Bazel. The
  only supported kind of plugins are annotation processors. A <code>java_library</code> or
  <code>java_binary</code> rule can run plugins by depending on them via the <code>plugins</code>
  attribute. A <code>java_library</code> can also automatically export plugins to libraries that
  directly depend on it using
  <code><a href="#java_library-exported_plugins">exported_plugins</a></code>.
</p>

<h4 id="java_plugin_implicit_outputs">Implicit output targets</h4>
    <ul>
      <li><code><var>libname</var>.jar</code>: A Java archive.</li>
    </ul>

<p>
  Arguments are identical to <a href="#java_library"><code>java_library</code></a>, except
  for the addition of the <code>processor_class</code> argument.
</p>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_plugin-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_plugin-deps"></a>deps |  The list of libraries to link into this library. See general comments about <code>deps</code> at <a href="${link common-definitions#typical-attributes}">Typical attributes defined by most build rules</a>. <p>   The jars built by <code>java_library</code> rules listed in <code>deps</code> will be on   the compile-time classpath of this rule. Furthermore the transitive closure of their   <code>deps</code>, <code>runtime_deps</code> and <code>exports</code> will be on the   runtime classpath. </p> <p>   By contrast, targets in the <code>data</code> attribute are included in the runfiles but   on neither the compile-time nor runtime classpath. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_plugin-srcs"></a>srcs |  The list of source files that are processed to create the target. This attribute is almost always required; see exceptions below. <p> Source files of type <code>.java</code> are compiled. In case of generated <code>.java</code> files it is generally advisable to put the generating rule's name here instead of the name of the file itself. This not only improves readability but makes the rule more resilient to future changes: if the generating rule generates different files in the future, you only need to fix one place: the <code>outs</code> of the generating rule. You should not list the generating rule in <code>deps</code> because it is a no-op. </p> <p> Source files of type <code>.srcjar</code> are unpacked and compiled. (This is useful if you need to generate a set of <code>.java</code> files with a genrule.) </p> <p> Rules: if the rule (typically <code>genrule</code> or <code>filegroup</code>) generates any of the files listed above, they will be used the same way as described for source files. </p> <p> Source files of type <code>.properties</code> are treated as resources. </p><br><br><p>All other files are ignored, as long as there is at least one file of a file type described above. Otherwise an error is raised.</p><br><br><p> This argument is almost always required, except if you specify the <code>runtime_deps</code> argument. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_plugin-data"></a>data |  The list of files needed by this library at runtime. See general comments about <code>data</code> at <a href="${link common-definitions#typical-attributes}">Typical attributes defined by most build rules</a>. <p>   When building a <code>java_library</code>, Bazel doesn't put these files anywhere; if the   <code>data</code> files are generated files then Bazel generates them. When building a   test that depends on this <code>java_library</code> Bazel copies or links the   <code>data</code> files into the runfiles area. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_plugin-resources"></a>resources |  A list of data files to include in a Java jar. <p> Resources may be source files or generated files. </p><br><br><p> If resources are specified, they will be bundled in the jar along with the usual <code>.class</code> files produced by compilation. The location of the resources inside of the jar file is determined by the project structure. Bazel first looks for Maven's <a href="https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html">standard directory layout</a>, (a "src" directory followed by a "resources" directory grandchild). If that is not found, Bazel then looks for the topmost directory named "java" or "javatests" (so, for example, if a resource is at <code>&lt;workspace root&gt;/x/java/y/java/z</code>, the path of the resource will be <code>y/java/z</code>. This heuristic cannot be overridden, however, the <code>resource_strip_prefix</code> attribute can be used to specify a specific alternative directory for resource files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_plugin-add_exports"></a>add_exports |  Allow this library to access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-exports= flags.   | List of strings | optional |  `[]`  |
| <a id="java_plugin-add_opens"></a>add_opens |  Allow this library to reflectively access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-opens= flags.   | List of strings | optional |  `[]`  |
| <a id="java_plugin-bootclasspath"></a>bootclasspath |  Restricted API, do not use!   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_plugin-generates_api"></a>generates_api |  This attribute marks annotation processors that generate API code. <p>If a rule uses an API-generating annotation processor, other rules depending on it can refer to the generated code only if their compilation actions are scheduled after the generating rule. This attribute instructs Bazel to introduce scheduling constraints when --java_header_compilation is enabled. <p><em class="harmful">WARNING: This attribute affects build performance, use it only if necessary.</em></p>   | Boolean | optional |  `False`  |
| <a id="java_plugin-javabuilder_jvm_flags"></a>javabuilder_jvm_flags |  Restricted API, do not use!   | List of strings | optional |  `[]`  |
| <a id="java_plugin-javacopts"></a>javacopts |  Extra compiler options for this library. Subject to <a href="make-variables.html">"Make variable"</a> substitution and <a href="common-definitions.html#sh-tokenization">Bourne shell tokenization</a>. <p>These compiler options are passed to javac after the global compiler options.</p>   | List of strings | optional |  `[]`  |
| <a id="java_plugin-licenses"></a>licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_plugin-neverlink"></a>neverlink |  Whether this library should only be used for compilation and not at runtime. Useful if the library will be provided by the runtime environment during execution. Examples of such libraries are the IDE APIs for IDE plug-ins or <code>tools.jar</code> for anything running on a standard JDK. <p>   Note that <code>neverlink = True</code> does not prevent the compiler from inlining material   from this library into compilation targets that depend on it, as permitted by the Java   Language Specification (e.g., <code>static final</code> constants of <code>String</code>   or of primitive types). The preferred use case is therefore when the runtime library is   identical to the compilation library. </p> <p>   If the runtime library differs from the compilation library then you must ensure that it   differs only in places that the JLS forbids compilers to inline (and that must hold for   all future versions of the JLS). </p>   | Boolean | optional |  `False`  |
| <a id="java_plugin-output_licenses"></a>output_licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_plugin-plugins"></a>plugins |  Java compiler plugins to run at compile-time. Every <code>java_plugin</code> specified in this attribute will be run whenever this rule is built. A library may also inherit plugins from dependencies that use <code><a href="#java_library.exported_plugins">exported_plugins</a></code>. Resources generated by the plugin will be included in the resulting jar of this rule.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_plugin-processor_class"></a>processor_class |  The processor class is the fully qualified type of the class that the Java compiler should use as entry point to the annotation processor. If not specified, this rule will not contribute an annotation processor to the Java compiler's annotation processing, but its runtime classpath will still be included on the compiler's annotation processor path. (This is primarily intended for use by <a href="https://errorprone.info/docs/plugins">Error Prone plugins</a>, which are loaded from the annotation processor path using <a href="https://docs.oracle.com/javase/8/docs/api/java/util/ServiceLoader.html"> java.util.ServiceLoader</a>.)   | String | optional |  `""`  |
| <a id="java_plugin-proguard_specs"></a>proguard_specs |  Files to be used as Proguard specification. These will describe the set of specifications to be used by Proguard. If specified, they will be added to any <code>android_binary</code> target depending on this library.<br><br>The files included here must only have idempotent rules, namely -dontnote, -dontwarn, assumenosideeffects, and rules that start with -keep. Other options can only appear in <code>android_binary</code>'s proguard_specs, to ensure non-tautological merges.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_plugin-resource_strip_prefix"></a>resource_strip_prefix |  The path prefix to strip from Java resources. <p> If specified, this path prefix is stripped from every file in the <code>resources</code> attribute. It is an error for a resource file not to be under this directory. If not specified (the default), the path of resource file is determined according to the same logic as the Java package of source files. For example, a source file at <code>stuff/java/foo/bar/a.txt</code> will be located at <code>foo/bar/a.txt</code>. </p>   | String | optional |  `""`  |


<a id="java_runtime"></a>

## java_runtime

<pre>
java_runtime(<a href="#java_runtime-name">name</a>, <a href="#java_runtime-srcs">srcs</a>, <a href="#java_runtime-default_cds">default_cds</a>, <a href="#java_runtime-hermetic_srcs">hermetic_srcs</a>, <a href="#java_runtime-hermetic_static_libs">hermetic_static_libs</a>, <a href="#java_runtime-java">java</a>, <a href="#java_runtime-java_home">java_home</a>,
             <a href="#java_runtime-lib_ct_sym">lib_ct_sym</a>, <a href="#java_runtime-lib_modules">lib_modules</a>, <a href="#java_runtime-output_licenses">output_licenses</a>, <a href="#java_runtime-version">version</a>)
</pre>

<p>
Specifies the configuration for a Java runtime.
</p>

<h4 id="java_runtime_example">Example:</h4>

<pre class="code">
<code class="lang-starlark">

java_runtime(
    name = "jdk-9-ea+153",
    srcs = glob(["jdk9-ea+153/**"]),
    java_home = "jdk9-ea+153",
)

</code>
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_runtime-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_runtime-srcs"></a>srcs |  All files in the runtime.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_runtime-default_cds"></a>default_cds |  Default CDS archive for hermetic <code>java_runtime</code>. When hermetic is enabled for a <code>java_binary</code> target and if the target does not provide its own CDS archive by specifying the <a href="${link java_binary.classlist}"><code>classlist</code></a> attribute, the <code>java_runtime</code> default CDS is packaged in the hermetic deploy JAR.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_runtime-hermetic_srcs"></a>hermetic_srcs |  Files in the runtime needed for hermetic deployments.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_runtime-hermetic_static_libs"></a>hermetic_static_libs |  The libraries that are statically linked with the launcher for hermetic deployments   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_runtime-java"></a>java |  The path to the java executable.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_runtime-java_home"></a>java_home |  The path to the root of the runtime. Subject to <a href="${link make-variables}">"Make" variable</a> substitution. If this path is absolute, the rule denotes a non-hermetic Java runtime with a well-known path. In that case, the <code>srcs</code> and <code>java</code> attributes must be empty.   | String | optional |  `""`  |
| <a id="java_runtime-lib_ct_sym"></a>lib_ct_sym |  The lib/ct.sym file needed for compilation with <code>--release</code>. If not specified and there is exactly one file in <code>srcs</code> whose path ends with <code>/lib/ct.sym</code>, that file is used.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_runtime-lib_modules"></a>lib_modules |  The lib/modules file needed for hermetic deployments.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_runtime-output_licenses"></a>output_licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_runtime-version"></a>version |  The feature version of the Java runtime. I.e., the integer returned by <code>Runtime.version().feature()</code>.   | Integer | optional |  `0`  |


<a id="java_test"></a>

## java_test

<pre>
java_test(<a href="#java_test-name">name</a>, <a href="#java_test-deps">deps</a>, <a href="#java_test-srcs">srcs</a>, <a href="#java_test-data">data</a>, <a href="#java_test-resources">resources</a>, <a href="#java_test-add_exports">add_exports</a>, <a href="#java_test-add_opens">add_opens</a>, <a href="#java_test-bootclasspath">bootclasspath</a>,
          <a href="#java_test-classpath_resources">classpath_resources</a>, <a href="#java_test-create_executable">create_executable</a>, <a href="#java_test-deploy_manifest_lines">deploy_manifest_lines</a>, <a href="#java_test-env">env</a>, <a href="#java_test-env_inherit">env_inherit</a>, <a href="#java_test-javacopts">javacopts</a>,
          <a href="#java_test-jvm_flags">jvm_flags</a>, <a href="#java_test-launcher">launcher</a>, <a href="#java_test-licenses">licenses</a>, <a href="#java_test-main_class">main_class</a>, <a href="#java_test-neverlink">neverlink</a>, <a href="#java_test-plugins">plugins</a>, <a href="#java_test-resource_strip_prefix">resource_strip_prefix</a>,
          <a href="#java_test-runtime_deps">runtime_deps</a>, <a href="#java_test-stamp">stamp</a>, <a href="#java_test-test_class">test_class</a>, <a href="#java_test-use_launcher">use_launcher</a>, <a href="#java_test-use_testrunner">use_testrunner</a>)
</pre>

<p>
A <code>java_test()</code> rule compiles a Java test. A test is a binary wrapper around your
test code. The test runner's main method is invoked instead of the main class being compiled.
</p>

<h4 id="java_test_implicit_outputs">Implicit output targets</h4>
<ul>
  <li><code><var>name</var>.jar</code>: A Java archive.</li>
  <li><code><var>name</var>_deploy.jar</code>: A Java archive suitable
    for deployment. (Only built if explicitly requested.) See the description of the
    <code><var>name</var>_deploy.jar</code> output from
    <a href="#java_binary">java_binary</a> for more details.</li>
</ul>

<p>
See the section on <code>java_binary()</code> arguments. This rule also
supports all <a href="https://bazel.build/reference/be/common-definitions#common-attributes-tests">attributes common
to all test rules (*_test)</a>.
</p>

<h4 id="java_test_examples">Examples</h4>

<pre class="code">
<code class="lang-starlark">

java_library(
    name = "tests",
    srcs = glob(["*.java"]),
    deps = [
        "//java/com/foo/base:testResources",
        "//java/com/foo/testing/util",
    ],
)

java_test(
    name = "AllTests",
    size = "small",
    runtime_deps = [
        ":tests",
        "//util/mysql",
    ],
)
</code>
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_test-deps"></a>deps |  The list of other libraries to be linked in to the target. See general comments about <code>deps</code> at <a href="common-definitions.html#typical-attributes">Typical attributes defined by most build rules</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-srcs"></a>srcs |  The list of source files that are processed to create the target. This attribute is almost always required; see exceptions below. <p> Source files of type <code>.java</code> are compiled. In case of generated <code>.java</code> files it is generally advisable to put the generating rule's name here instead of the name of the file itself. This not only improves readability but makes the rule more resilient to future changes: if the generating rule generates different files in the future, you only need to fix one place: the <code>outs</code> of the generating rule. You should not list the generating rule in <code>deps</code> because it is a no-op. </p> <p> Source files of type <code>.srcjar</code> are unpacked and compiled. (This is useful if you need to generate a set of <code>.java</code> files with a genrule.) </p> <p> Rules: if the rule (typically <code>genrule</code> or <code>filegroup</code>) generates any of the files listed above, they will be used the same way as described for source files. </p><br><br><p> This argument is almost always required, except if a <a href="#java_binary.main_class"><code>main_class</code></a> attribute specifies a class on the runtime classpath or you specify the <code>runtime_deps</code> argument. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-data"></a>data |  The list of files needed by this library at runtime. See general comments about <code>data</code> at <a href="${link common-definitions#typical-attributes}">Typical attributes defined by most build rules</a>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-resources"></a>resources |  A list of data files to include in a Java jar.<br><br><p> Resources may be source files or generated files. </p><br><br><p> If resources are specified, they will be bundled in the jar along with the usual <code>.class</code> files produced by compilation. The location of the resources inside of the jar file is determined by the project structure. Bazel first looks for Maven's <a href="https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html">standard directory layout</a>, (a "src" directory followed by a "resources" directory grandchild). If that is not found, Bazel then looks for the topmost directory named "java" or "javatests" (so, for example, if a resource is at <code>&lt;workspace root&gt;/x/java/y/java/z</code>, the path of the resource will be <code>y/java/z</code>. This heuristic cannot be overridden, however, the <code>resource_strip_prefix</code> attribute can be used to specify a specific alternative directory for resource files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-add_exports"></a>add_exports |  Allow this library to access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-exports= flags.   | List of strings | optional |  `[]`  |
| <a id="java_test-add_opens"></a>add_opens |  Allow this library to reflectively access the given <code>module</code> or <code>package</code>. <p> This corresponds to the javac and JVM --add-opens= flags.   | List of strings | optional |  `[]`  |
| <a id="java_test-bootclasspath"></a>bootclasspath |  Restricted API, do not use!   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_test-classpath_resources"></a>classpath_resources |  <em class="harmful">DO NOT USE THIS OPTION UNLESS THERE IS NO OTHER WAY)</em> <p> A list of resources that must be located at the root of the java tree. This attribute's only purpose is to support third-party libraries that require that their resources be found on the classpath as exactly <code>"myconfig.xml"</code>. It is only allowed on binaries and not libraries, due to the danger of namespace conflicts. </p>   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-create_executable"></a>create_executable |  Deprecated, use <code>java_single_jar</code> instead.   | Boolean | optional |  `True`  |
| <a id="java_test-deploy_manifest_lines"></a>deploy_manifest_lines |  A list of lines to add to the <code>META-INF/manifest.mf</code> file generated for the <code>*_deploy.jar</code> target. The contents of this attribute are <em>not</em> subject to <a href="make-variables.html">"Make variable"</a> substitution.   | List of strings | optional |  `[]`  |
| <a id="java_test-env"></a>env |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="java_test-env_inherit"></a>env_inherit |  -   | List of strings | optional |  `[]`  |
| <a id="java_test-javacopts"></a>javacopts |  Extra compiler options for this binary. Subject to <a href="make-variables.html">"Make variable"</a> substitution and <a href="common-definitions.html#sh-tokenization">Bourne shell tokenization</a>. <p>These compiler options are passed to javac after the global compiler options.</p>   | List of strings | optional |  `[]`  |
| <a id="java_test-jvm_flags"></a>jvm_flags |  A list of flags to embed in the wrapper script generated for running this binary. Subject to <a href="${link make-variables#location}">$(location)</a> and <a href="make-variables.html">"Make variable"</a> substitution, and <a href="common-definitions.html#sh-tokenization">Bourne shell tokenization</a>.<br><br><p>The wrapper script for a Java binary includes a CLASSPATH definition (to find all the dependent jars) and invokes the right Java interpreter. The command line generated by the wrapper script includes the name of the main class followed by a <code>"$@"</code> so you can pass along other arguments after the classname.  However, arguments intended for parsing by the JVM must be specified <i>before</i> the classname on the command line.  The contents of <code>jvm_flags</code> are added to the wrapper script before the classname is listed.</p><br><br><p>Note that this attribute has <em>no effect</em> on <code>*_deploy.jar</code> outputs.</p>   | List of strings | optional |  `[]`  |
| <a id="java_test-launcher"></a>launcher |  Specify a binary that will be used to run your Java program instead of the normal <code>bin/java</code> program included with the JDK. The target must be a <code>cc_binary</code>. Any <code>cc_binary</code> that implements the <a href="http://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/invocation.html"> Java Invocation API</a> can be specified as a value for this attribute.<br><br><p>By default, Bazel will use the normal JDK launcher (bin/java or java.exe).</p><br><br><p>The related <a href="${link user-manual#flag--java_launcher}"><code> --java_launcher</code></a> Bazel flag affects only those <code>java_binary</code> and <code>java_test</code> targets that have <i>not</i> specified a <code>launcher</code> attribute.</p><br><br><p>Note that your native (C++, SWIG, JNI) dependencies will be built differently depending on whether you are using the JDK launcher or another launcher:</p><br><br><ul> <li>If you are using the normal JDK launcher (the default), native dependencies are built as a shared library named <code>{name}_nativedeps.so</code>, where <code>{name}</code> is the <code>name</code> attribute of this java_binary rule. Unused code is <em>not</em> removed by the linker in this configuration.</li><br><br><li>If you are using any other launcher, native (C++) dependencies are statically linked into a binary named <code>{name}_nativedeps</code>, where <code>{name}</code> is the <code>name</code> attribute of this java_binary rule. In this case, the linker will remove any code it thinks is unused from the resulting binary, which means any C++ code accessed only via JNI may not be linked in unless that <code>cc_library</code> target specifies <code>alwayslink = True</code>.</li> </ul><br><br><p>When using any launcher other than the default JDK launcher, the format of the <code>*_deploy.jar</code> output changes. See the main <a href="#java_binary">java_binary</a> docs for details.</p>   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_test-licenses"></a>licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_test-main_class"></a>main_class |  Name of class with <code>main()</code> method to use as entry point. If a rule uses this option, it does not need a <code>srcs=[...]</code> list. Thus, with this attribute one can make an executable from a Java library that already contains one or more <code>main()</code> methods. <p> The value of this attribute is a class name, not a source file. The class must be available at runtime: it may be compiled by this rule (from <code>srcs</code>) or provided by direct or transitive dependencies (through <code>runtime_deps</code> or <code>deps</code>). If the class is unavailable, the binary will fail at runtime; there is no build-time check. </p>   | String | optional |  `""`  |
| <a id="java_test-neverlink"></a>neverlink |  -   | Boolean | optional |  `False`  |
| <a id="java_test-plugins"></a>plugins |  Java compiler plugins to run at compile-time. Every <code>java_plugin</code> specified in this attribute will be run whenever this rule is built. A library may also inherit plugins from dependencies that use <code><a href="#java_library.exported_plugins">exported_plugins</a></code>. Resources generated by the plugin will be included in the resulting jar of this rule.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-resource_strip_prefix"></a>resource_strip_prefix |  The path prefix to strip from Java resources. <p> If specified, this path prefix is stripped from every file in the <code>resources</code> attribute. It is an error for a resource file not to be under this directory. If not specified (the default), the path of resource file is determined according to the same logic as the Java package of source files. For example, a source file at <code>stuff/java/foo/bar/a.txt</code> will be located at <code>foo/bar/a.txt</code>. </p>   | String | optional |  `""`  |
| <a id="java_test-runtime_deps"></a>runtime_deps |  Libraries to make available to the final binary or test at runtime only. Like ordinary <code>deps</code>, these will appear on the runtime classpath, but unlike them, not on the compile-time classpath. Dependencies needed only at runtime should be listed here. Dependency-analysis tools should ignore targets that appear in both <code>runtime_deps</code> and <code>deps</code>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_test-stamp"></a>stamp |  Whether to encode build information into the binary. Possible values: <ul> <li>   <code>stamp = 1</code>: Always stamp the build information into the binary, even in   <a href="https://bazel.build/docs/user-manual#stamp"><code>--nostamp</code></a> builds. <b>This   setting should be avoided</b>, since it potentially kills remote caching for the   binary and any downstream actions that depend on it. </li> <li>   <code>stamp = 0</code>: Always replace build information by constant values. This   gives good build result caching. </li> <li>   <code>stamp = -1</code>: Embedding of build information is controlled by the   <a href="https://bazel.build/docs/user-manual#stamp"><code>--[no]stamp</code></a> flag. </li> </ul> <p>Stamped binaries are <em>not</em> rebuilt unless their dependencies change.</p>   | Integer | optional |  `0`  |
| <a id="java_test-test_class"></a>test_class |  The Java class to be loaded by the test runner.<br/> <p>   By default, if this argument is not defined then the legacy mode is used and the   test arguments are used instead. Set the <code>--nolegacy_bazel_java_test</code> flag   to not fallback on the first argument. </p> <p>   This attribute specifies the name of a Java class to be run by   this test. It is rare to need to set this. If this argument is omitted,   it will be inferred using the target's <code>name</code> and its   source-root-relative path. If the test is located outside a known   source root, Bazel will report an error if <code>test_class</code>   is unset. </p> <p>   For JUnit3, the test class needs to either be a subclass of   <code>junit.framework.TestCase</code> or it needs to have a public   static <code>suite()</code> method that returns a   <code>junit.framework.Test</code> (or a subclass of <code>Test</code>).   For JUnit4, the class needs to be annotated with   <code>org.junit.runner.RunWith</code>. </p> <p>   This attribute allows several <code>java_test</code> rules to   share the same <code>Test</code>   (<code>TestCase</code>, <code>TestSuite</code>, ...).  Typically   additional information is passed to it   (e.g. via <code>jvm_flags=['-Dkey=value']</code>) so that its   behavior differs in each case, such as running a different   subset of the tests.  This attribute also enables the use of   Java tests outside the <code>javatests</code> tree. </p>   | String | optional |  `""`  |
| <a id="java_test-use_launcher"></a>use_launcher |  Whether the binary should use a custom launcher.<br><br><p>If this attribute is set to false, the <a href="${link java_binary.launcher}">launcher</a> attribute  and the related <a href="${link user-manual#flag--java_launcher}"><code>--java_launcher</code></a> flag will be ignored for this target.   | Boolean | optional |  `True`  |
| <a id="java_test-use_testrunner"></a>use_testrunner |  Use the test runner (by default <code>com.google.testing.junit.runner.BazelTestRunner</code>) class as the main entry point for a Java program, and provide the test class to the test runner as a value of <code>bazel.test_suite</code> system property.<br><br><br/> You can use this to override the default behavior, which is to use test runner for <code>java_test</code> rules, and not use it for <code>java_binary</code> rules.  It is unlikely you will want to do this.  One use is for <code>AllTest</code> rules that are invoked by another rule (to set up a database before running the tests, for example).  The <code>AllTest</code> rule must be declared as a <code>java_binary</code>, but should still use the test runner as its main entry point.<br><br>The name of a test runner class can be overridden with <code>main_class</code> attribute.   | Boolean | optional |  `True`  |


<a id="java_toolchain"></a>

## java_toolchain

<pre>
java_toolchain(<a href="#java_toolchain-name">name</a>, <a href="#java_toolchain-android_lint_data">android_lint_data</a>, <a href="#java_toolchain-android_lint_jvm_opts">android_lint_jvm_opts</a>, <a href="#java_toolchain-android_lint_opts">android_lint_opts</a>,
               <a href="#java_toolchain-android_lint_package_configuration">android_lint_package_configuration</a>, <a href="#java_toolchain-android_lint_runner">android_lint_runner</a>, <a href="#java_toolchain-bootclasspath">bootclasspath</a>,
               <a href="#java_toolchain-compatible_javacopts">compatible_javacopts</a>, <a href="#java_toolchain-deps_checker">deps_checker</a>, <a href="#java_toolchain-forcibly_disable_header_compilation">forcibly_disable_header_compilation</a>, <a href="#java_toolchain-genclass">genclass</a>,
               <a href="#java_toolchain-header_compiler">header_compiler</a>, <a href="#java_toolchain-header_compiler_builtin_processors">header_compiler_builtin_processors</a>, <a href="#java_toolchain-header_compiler_direct">header_compiler_direct</a>, <a href="#java_toolchain-ijar">ijar</a>,
               <a href="#java_toolchain-jacocorunner">jacocorunner</a>, <a href="#java_toolchain-java_runtime">java_runtime</a>, <a href="#java_toolchain-javabuilder">javabuilder</a>, <a href="#java_toolchain-javabuilder_data">javabuilder_data</a>, <a href="#java_toolchain-javabuilder_jvm_opts">javabuilder_jvm_opts</a>,
               <a href="#java_toolchain-javac_supports_multiplex_workers">javac_supports_multiplex_workers</a>, <a href="#java_toolchain-javac_supports_worker_cancellation">javac_supports_worker_cancellation</a>,
               <a href="#java_toolchain-javac_supports_worker_multiplex_sandboxing">javac_supports_worker_multiplex_sandboxing</a>, <a href="#java_toolchain-javac_supports_workers">javac_supports_workers</a>, <a href="#java_toolchain-javacopts">javacopts</a>,
               <a href="#java_toolchain-jspecify_implicit_deps">jspecify_implicit_deps</a>, <a href="#java_toolchain-jspecify_javacopts">jspecify_javacopts</a>, <a href="#java_toolchain-jspecify_packages">jspecify_packages</a>, <a href="#java_toolchain-jspecify_processor">jspecify_processor</a>,
               <a href="#java_toolchain-jspecify_processor_class">jspecify_processor_class</a>, <a href="#java_toolchain-jspecify_stubs">jspecify_stubs</a>, <a href="#java_toolchain-jvm_opts">jvm_opts</a>, <a href="#java_toolchain-licenses">licenses</a>, <a href="#java_toolchain-misc">misc</a>, <a href="#java_toolchain-oneversion">oneversion</a>,
               <a href="#java_toolchain-oneversion_allowlist">oneversion_allowlist</a>, <a href="#java_toolchain-oneversion_allowlist_for_tests">oneversion_allowlist_for_tests</a>, <a href="#java_toolchain-oneversion_whitelist">oneversion_whitelist</a>,
               <a href="#java_toolchain-package_configuration">package_configuration</a>, <a href="#java_toolchain-proguard_allowlister">proguard_allowlister</a>, <a href="#java_toolchain-reduced_classpath_incompatible_processors">reduced_classpath_incompatible_processors</a>,
               <a href="#java_toolchain-singlejar">singlejar</a>, <a href="#java_toolchain-source_version">source_version</a>, <a href="#java_toolchain-target_version">target_version</a>, <a href="#java_toolchain-timezone_data">timezone_data</a>, <a href="#java_toolchain-tools">tools</a>, <a href="#java_toolchain-turbine_data">turbine_data</a>,
               <a href="#java_toolchain-turbine_jvm_opts">turbine_jvm_opts</a>, <a href="#java_toolchain-xlint">xlint</a>)
</pre>

<p>
Specifies the configuration for the Java compiler. Which toolchain to be used can be changed through
the --java_toolchain argument. Normally you should not write those kind of rules unless you want to
tune your Java compiler.
</p>

<h4>Examples</h4>

<p>A simple example would be:
</p>

<pre class="code">
<code class="lang-starlark">

java_toolchain(
    name = "toolchain",
    source_version = "7",
    target_version = "7",
    bootclasspath = ["//tools/jdk:bootclasspath"],
    xlint = [ "classfile", "divzero", "empty", "options", "path" ],
    javacopts = [ "-g" ],
    javabuilder = ":JavaBuilder_deploy.jar",
)
</code>
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="java_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="java_toolchain-android_lint_data"></a>android_lint_data |  Labels of tools available for label-expansion in android_lint_jvm_opts.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-android_lint_jvm_opts"></a>android_lint_jvm_opts |  The list of arguments for the JVM when invoking Android Lint.   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-android_lint_opts"></a>android_lint_opts |  The list of Android Lint arguments.   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-android_lint_package_configuration"></a>android_lint_package_configuration |  Android Lint Configuration that should be applied to the specified package groups.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-android_lint_runner"></a>android_lint_runner |  Label of the Android Lint runner, if any.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-bootclasspath"></a>bootclasspath |  The Java target bootclasspath entries. Corresponds to javac's -bootclasspath flag.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-compatible_javacopts"></a>compatible_javacopts |  Internal API, do not use!   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> List of strings</a> | optional |  `{}`  |
| <a id="java_toolchain-deps_checker"></a>deps_checker |  Label of the ImportDepsChecker deploy jar.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-forcibly_disable_header_compilation"></a>forcibly_disable_header_compilation |  Overrides --java_header_compilation to disable header compilation on platforms that do not support it, e.g. JDK 7 Bazel.   | Boolean | optional |  `False`  |
| <a id="java_toolchain-genclass"></a>genclass |  Label of the GenClass deploy jar.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-header_compiler"></a>header_compiler |  Label of the header compiler. Required if --java_header_compilation is enabled.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-header_compiler_builtin_processors"></a>header_compiler_builtin_processors |  Internal API, do not use!   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-header_compiler_direct"></a>header_compiler_direct |  Optional label of the header compiler to use for direct classpath actions that do not include any API-generating annotation processors.<br><br><p>This tool does not support annotation processing.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-ijar"></a>ijar |  Label of the ijar executable.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-jacocorunner"></a>jacocorunner |  Label of the JacocoCoverageRunner deploy jar.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-java_runtime"></a>java_runtime |  The java_runtime to use with this toolchain. It defaults to java_runtime in execution configuration.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-javabuilder"></a>javabuilder |  Label of the JavaBuilder deploy jar.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-javabuilder_data"></a>javabuilder_data |  Labels of data available for label-expansion in javabuilder_jvm_opts.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-javabuilder_jvm_opts"></a>javabuilder_jvm_opts |  The list of arguments for the JVM when invoking JavaBuilder.   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-javac_supports_multiplex_workers"></a>javac_supports_multiplex_workers |  True if JavaBuilder supports running as a multiplex persistent worker, false if it doesn't.   | Boolean | optional |  `True`  |
| <a id="java_toolchain-javac_supports_worker_cancellation"></a>javac_supports_worker_cancellation |  True if JavaBuilder supports cancellation of persistent workers, false if it doesn't.   | Boolean | optional |  `True`  |
| <a id="java_toolchain-javac_supports_worker_multiplex_sandboxing"></a>javac_supports_worker_multiplex_sandboxing |  True if JavaBuilder supports running as a multiplex persistent worker with sandboxing, false if it doesn't.   | Boolean | optional |  `False`  |
| <a id="java_toolchain-javac_supports_workers"></a>javac_supports_workers |  True if JavaBuilder supports running as a persistent worker, false if it doesn't.   | Boolean | optional |  `True`  |
| <a id="java_toolchain-javacopts"></a>javacopts |  The list of extra arguments for the Java compiler. Please refer to the Java compiler documentation for the extensive list of possible Java compiler flags.   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-jspecify_implicit_deps"></a>jspecify_implicit_deps |  Experimental, do not use!   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-jspecify_javacopts"></a>jspecify_javacopts |  Experimental, do not use!   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-jspecify_packages"></a>jspecify_packages |  Experimental, do not use!   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-jspecify_processor"></a>jspecify_processor |  Experimental, do not use!   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-jspecify_processor_class"></a>jspecify_processor_class |  Experimental, do not use!   | String | optional |  `""`  |
| <a id="java_toolchain-jspecify_stubs"></a>jspecify_stubs |  Experimental, do not use!   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-jvm_opts"></a>jvm_opts |  The list of arguments for the JVM when invoking the Java compiler. Please refer to the Java virtual machine documentation for the extensive list of possible flags for this option.   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-licenses"></a>licenses |  -   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-misc"></a>misc |  Deprecated: use javacopts instead   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-oneversion"></a>oneversion |  Label of the one-version enforcement binary.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-oneversion_allowlist"></a>oneversion_allowlist |  Label of the one-version allowlist.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-oneversion_allowlist_for_tests"></a>oneversion_allowlist_for_tests |  Label of the one-version allowlist for tests.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-oneversion_whitelist"></a>oneversion_whitelist |  Deprecated: use oneversion_allowlist instead   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-package_configuration"></a>package_configuration |  Configuration that should be applied to the specified package groups.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-proguard_allowlister"></a>proguard_allowlister |  Label of the Proguard allowlister.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@bazel_tools//tools/jdk:proguard_whitelister"`  |
| <a id="java_toolchain-reduced_classpath_incompatible_processors"></a>reduced_classpath_incompatible_processors |  Internal API, do not use!   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-singlejar"></a>singlejar |  Label of the SingleJar deploy jar.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-source_version"></a>source_version |  The Java source version (e.g., '6' or '7'). It specifies which set of code structures are allowed in the Java source code.   | String | optional |  `""`  |
| <a id="java_toolchain-target_version"></a>target_version |  The Java target version (e.g., '6' or '7'). It specifies for which Java runtime the class should be build.   | String | optional |  `""`  |
| <a id="java_toolchain-timezone_data"></a>timezone_data |  Label of a resource jar containing timezone data. If set, the timezone data is added as an implicitly runtime dependency of all java_binary rules.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="java_toolchain-tools"></a>tools |  Labels of tools available for label-expansion in jvm_opts.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-turbine_data"></a>turbine_data |  Labels of data available for label-expansion in turbine_jvm_opts.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="java_toolchain-turbine_jvm_opts"></a>turbine_jvm_opts |  The list of arguments for the JVM when invoking turbine.   | List of strings | optional |  `[]`  |
| <a id="java_toolchain-xlint"></a>xlint |  The list of warning to add or removes from default list. Precedes it with a dash to removes it. Please see the Javac documentation on the -Xlint options for more information.   | List of strings | optional |  `[]`  |


