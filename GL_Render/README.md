* bezier.pl  
* Draw_Bitmap.pl  
* Draw_Outline_Curves.pl  
* Draw_Outline_Fill.pl  
* Draw_Outline_Points.pl  
* playing.pl  
* Show_String.pl  
  * tag v0.1  
    存储一小段字符串并显示部分内容  
    `our $text = "九霄龙吟惊天变风云际会浅水游". join('', a..z, A..Z);`  
    内存占用 30MB左右  
    如果读取msyh.ttf所有字符轮廓数据，并转为数组，会导致爆内存。
  * tab v0.3
    解决爆内存问题
* Show_String_Colorful.pl  
  ![pic](https://github.com/vicyang/Font-Freetype-Usage/blob/master/GL_Render/colorful.png)

* 参考
  [汉字 Unicode 编码范围](http://www.qqxiuzi.cn/zh/hanzi-unicode-bianma.php)
