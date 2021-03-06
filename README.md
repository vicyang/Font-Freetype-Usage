### Font::Freetype  
关于Font::Freetype 模块的安装和代码示例  

* #### 安装
  模块地址：[Font::FreeType](https://metacpan.org/pod/Font::FreeType)  
  推荐环境：Win7, Strawberry Perl V5.24 Portable  
  参考：[Strawberry Perl 环境配置 以及 版本推荐](http://code-by.org/viewtopic.php?f=17&t=272)  
  
  解压后执行  
  >perl Makefile.PL  

  * 提示  
    ```
    Build config: default
    Build flag LIB: -lfreetype
    Build flag INC: -I/usr/include/freetype2
    Can't link/include C library 'ft2build.h', 'freetype', aborting.
    ```
  
  * 解决方法  
    Strawberry Perl V5.24 已经集成了C编译环境以及附带freetype库文件，只要设置好路径就行了。

    打开 Makefile.PL，找到  
    `$config->{default}{INC} = '-I/usr/include/freetype2';`  

    改为    
    `$config->{default}{INC} = '-IC:/Strawberry/c/include/freetype2';`
  
    然后  
    > perl Makefile.PL  
    > dmake  
    > dmake install  

