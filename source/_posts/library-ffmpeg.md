title: ffmpeg学习笔记
date: 2016-04-06 13:21:11
tags: [FFMPEG]
categories: [FFMPEG]
---
官网：http://ffmpeg.org
Wiki：http://trac.ffmpeg.org

<!-- more -->

# 编译安装
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
./configure
编译可选项 --
make
make install
PREFIX/bin ffmpeg   ffplay   ffprobe  ffserver
PREFIX/include libxxx/yyy.h
PREFIX/lib libxxx.a
PREFIX/share 系统相关东西，包括文档和示例

libavcodec encoding/decoding library
libavfilter graph-based frame editing library
libavformat I/O and muxing/demuxing library
libavdevice special devices muxing/demuxing library
libavutil common utility library
libswresample audio resampling, format conversion and mixing
libpostproc post processing library
libswscale color conversion and scaling library

libavutil 常规使用的工具类     
libavcodec     encoding decoding
libavformat    muxing demuxing
libavdevice    抓取输入设备渲染到输出设备
libavfilter       音视频过滤
libswscale     scaling，像素转换 
libswresample   audio采样、格式转变
libpostproc  video后处理
libavresample 

# 命令
ffmpeg   ffplay   ffprobe  ffserver
- ffmpeg   
- ffplay   
- ffprobe  
- ffserver
## ffmpeg
http://www.cnblogs.com/dwdxdy/p/3240167.html
从视频文件分离出视频和音频：
ffmpeg -i test.mp4 -vn -acodec copy -f adts test.mp3
ffmpeg -i test.mp4 -an -vcodec copy  test1.flv

ffmpeg -i zhibo.flv -vn -acodec copy -f adts zhibo.mp3
ffmpeg -i zhibo.flv -an -vcodec copy -f flv zhibo1.flv

常用参数说明：
主要参数：
-i 设定输入流
-f 设定输出格式
-ss 开始时间
视频参数：
-b 设定视频流量，默认为200Kbit/s
-r 设定帧速率，默认为25
-s 设定画面的宽与高
-aspect 设定画面的比例
-vn 不处理视频
-vcodec 设定视频编解码器，未设定时则使用与输入流相同的编解码器
音频参数：
-ar 设定采样率
-ac 设定声音的Channel数
-acodec 设定声音编解码器，未设定时则使用与输入流相同的编解码器
-an 不处理音频

只采集音频：
ffmpeg -f avfoundation -vn -i "1:0" -acodec aac ~/Downloads/a.aac

采集PCM音频： 
ffmpeg -f avfoundation -vn -i "1:0" -acodec pcm_f32le ~/Downloads/a.wav


# 编程
https://www.ffmpeg.org/doxygen/trunk/index.html

AVCodecContext 音频
```
    /* audio only */
    int sample_rate; ///< samples per second
    int channels;    ///< number of audio channels

    /**
     * audio sample format
     * - encoding: Set by user.
     * - decoding: Set by libavcodec.
     */
    enum AVSampleFormat sample_fmt;  ///< sample format

    /* The following data should not be initialized. */
    /**
     * Number of samples per channel in an audio frame.
     *
     * - encoding: set by libavcodec in avcodec_open2(). Each submitted frame
     *   except the last must contain exactly frame_size samples per channel.
     *   May be 0 when the codec has CODEC_CAP_VARIABLE_FRAME_SIZE set, then the
     *   frame size is not restricted.
     * - decoding: may be set by some decoders to indicate constant frame size
     */
    int frame_size;
```
AVFrame 音频
```
/**
     * pointer to the picture/channel planes.
     * This might be different from the first allocated byte
     *
     * Some decoders access areas outside 0,0 - width,height, please
     * see avcodec_align_dimensions2(). Some filters and swscale can read
     * up to 16 bytes beyond the planes, if these filters are to be used,
     * then 16 extra bytes must be allocated.
     */
    uint8_t *data[AV_NUM_DATA_POINTERS];

    /**
     * number of audio samples (per channel) described by this frame
     */
    int nb_samples;

    /**
     * format of the frame, -1 if unknown or unset
     * Values correspond to enum AVPixelFormat for video frames,
     * enum AVSampleFormat for audio)
     */
    int format;

    /**
     * Presentation timestamp in time_base units (time when frame should be shown to user).
     */
    int64_t pts;

    /**
     * PTS copied from the AVPacket that was decoded to produce this frame.
     */
    int64_t pkt_pts;

    /**
     * DTS copied from the AVPacket that triggered returning this frame. (if frame threading isn't used)
     * This is also the Presentation time of this AVFrame calculated from
     * only AVPacket.dts values without pts values.
     */
    int64_t pkt_dts;

    /**
     * Sample rate of the audio data.
     */
    int sample_rate;

    /**
     * number of audio channels, only used for audio.
     * Code outside libavcodec should access this field using:
     * av_frame_get_channels(frame)
     * - encoding: unused
     * - decoding: Read by user.
     */
    int channels;




```