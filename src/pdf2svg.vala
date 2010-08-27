/**
 * Copyright 2010 Jakob Westhoff. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice,
 *       this list of conditions and the following disclaimer in the documentation
 *       and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The views and conclusions contained in the software and documentation are those
 * of the authors and should not be interpreted as representing official policies,
 * either expressed or implied, of Jakob Westhoff
 */

using GLib;

namespace org.westhoffswelt.pdf2svg {

    /**
     * pdf2svg main application class
     *
     * This class contains all the initialization code like commandline
     * handling, as well as file and directory handling.
     * The conversion itself is NOT implemented in this class
     */
    public class Pdf2Svg: Object {
        
        /**
         * Options for the commandline parser
         */
        const OptionEntry[] options = {
            { "output", 'o', 0, OptionArg.STRING, ref Pdf2Svg.output_directory, "Directory used to store the created SVG files. (Default: Current working directory)", "DIRECTORY" },
            { "prefix", 'p', 0, OptionArg.STRING, ref Pdf2Svg.svg_prefix, "Prefix used for the created SVG files. (Default: Input filename with the extension stripped)", "PREFIX" },
            { "digits", 'd', 0, OptionArg.INT, ref Pdf2Svg.page_number_digits, "Number of digits to use for page numbering. (Default: 3)", "N" },
            { null }
        };

        /**
         * Output directory used to store the generated SVG files.
         */
        protected static string output_directory = null;

        /**
         * Prefix used to name the generated SVG files.
         */
        protected static string svg_prefix = null;

        /**
         * Number of digits to use for the page numbering
         */
        protected static int page_number_digits = 0;

        /**
         * Format string used to create output filename
         */
        protected string svg_output_format = null;

        /**
         * Run the main application.
         *
         * This method exists to execute all needed init code inside the object
         * scope instead of being run statically inside the main function
         */
        protected int run( string[] args ) {
            stdout.printf( "pdf2svg Version 1.x DEVELOPMENT Copyright 2010 Jakob Westhoff\n" );

            this.parse_command_line_options( args );
            this.ensure_default_options( args );

            File output_directory = File.new_for_commandline_arg( Pdf2Svg.output_directory );
            if ( !output_directory.query_exists( null ) ) {
                stderr.printf( "Error: Output directory does not exist.\n" );
                Posix.exit( 2 );
            }

            File pdf_file = File.new_for_commandline_arg( args[1] );
            if ( !pdf_file.query_exists( null ) ) {
                stderr.printf( "Error: PDF file does not exist.\n" );
                Posix.exit( 2 );
            }
            
            Transformer transformer = new Transformer( pdf_file );

            for( int i = 0, l = transformer.get_number_of_pages(); i < l; ++i ) {
                try {
                    stdout.printf( "Transforming page %i.\n", i+1 );
                    transformer.render_page_to_svg( 
                        i,
                        this.create_svg_output_filename_for_page( i ) 
                    );
                }
                catch( Error e ) {
                    error( "Fatal error transforming page %i: %s.", i+1, e.message );
                }
            }
/*

            var page_number = args[2].to_int();
            var output = args[3];
            
            try {
                var document = new Poppler.Document.from_file( pdf_file.get_uri(), null );
                var page = document.get_page( page_number );

                double width, height;
                page.get_size( out width, out height );
                
                var surface = new Cairo.SvgSurface( output, width, height );
                var context = new Cairo.Context( surface );

                page.render( context );

                return 0;
            }
            catch( Error e ) {
                error( "Oops: %s", e.message );
            }*/
            return 0;
        }

        /**
         * Parse the commandline and apply all found options to there according
         * static class members.
         *
         * On error the usage help is shown and the application terminated with an
         * errorcode 1
         */
        protected void parse_command_line_options( string[] args ) {
            var context = new OptionContext( "<pdf-file>" );

            context.add_main_entries( options, null );
            
            try {
                context.parse( ref args );
            }
            catch( OptionError e ) {
                stderr.printf( "\n%s\n\n", e.message );
                stderr.printf( "%s", context.get_help( true, null ) );
                Posix.exit( 1 );
            }

            // Make sure there is still an argument (pdf-file) specified after
            // the options have been parsed
            if ( args.length != 2 ) {
                stderr.printf( "%s", context.get_help( true, null ) );
                Posix.exit( 1 );
            }
        }

        /**
         * Ensure that all the default values for any non given commandline
         * option is set properly
         */
        protected void ensure_default_options( string[] args ) {
            if ( Pdf2Svg.output_directory == null ) {
                Pdf2Svg.output_directory = Environment.get_current_dir();
            }

            if ( Pdf2Svg.svg_prefix == null ) {
                var filepath = Path.get_basename( args[1] );
                var pSuffix = filepath.rchr( -1, ".".get_char() );
                 
                if ( pSuffix == null ) {
                    Pdf2Svg.svg_prefix = filepath;
                }
                else {
                    long position = filepath.length - pSuffix.length;
                    Pdf2Svg.svg_prefix = filepath.slice( 0, position );
                }
            }

            if ( Pdf2Svg.page_number_digits < 1 ) {
                Pdf2Svg.page_number_digits = 3;
            }
        }

        /**
         * Create and return a correctly formated output filename with correct
         * path for an arbitrary pdf page number.
         */
        protected string create_svg_output_filename_for_page( int i ) {
            if ( this.svg_output_format == null ) {
                var fmt = new StringBuilder();
                fmt.append( Pdf2Svg.output_directory );
                fmt.append( Path.DIR_SEPARATOR_S );
                fmt.append( Pdf2Svg.svg_prefix );
                fmt.append( "%0" );
                fmt.append( Pdf2Svg.page_number_digits.to_string() );
                fmt.append( "d" );
                fmt.append( ".svg" );
                this.svg_output_format = fmt.str;
            }
            return this.svg_output_format.printf( i );
        }

        /**
         * Application entry point
         */
        public static int main ( string[] args ) {
            var pdf2svg = new Pdf2Svg();
            return pdf2svg.run( args );
        }

    }

}
