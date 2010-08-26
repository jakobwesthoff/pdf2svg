using GLib;

namespace org.westhoffswelt.pdf2svg {

    public class Pdf2Svg: Object {
        protected int run( string[] args ) {
            var pdf_file = File.new_for_commandline_arg( args[1] );
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
            }
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
